---
title: Use Recovery Points for Multi-Step Idempotent Operations
impact: MEDIUM-HIGH
impactDescription: prevents partial-completion bugs when a multi-step operation crashes mid-execution
tags: idem, recovery, state-machine, durability
---

## Use Recovery Points for Multi-Step Idempotent Operations

A `POST /v1/charges` request isn't a single atomic operation — internally it might (a) authorise the card, (b) write a row to the charges table, (c) enqueue a webhook event, (d) update the customer's balance. If the server crashes between (b) and (c), the customer is charged but no webhook fires. Simply returning the cached response on retry isn't enough — the retry needs to *resume* from where the original failed.

The recovery-point pattern (Brandur Leach) handles this: persist a `recovery_point` field on the idempotency key record at each phase boundary (`started` → `card_authorized` → `charge_persisted` → `webhook_enqueued` → `finished`). On retry, the server reads the recovery point and resumes from the next phase, executing each remaining step idempotently. The cached response is returned only when `recovery_point = 'finished'`.

**Incorrect (single-phase idempotency — partial failures lose work):**

```python
def post_charge(account_id, key, params):
    cached = get_cached(account_id, key)
    if cached:
        return cached.response
    # All-or-nothing — if we crash mid-way, the next retry executes everything again,
    # but step (a) has side effects we can't undo (card already charged at the network).
    auth = card_network.authorize(params)
    charge = db.insert_charge(params, auth)
    webhook_queue.enqueue('charge.created', charge)
    balance_service.update(account_id, charge.amount)
    save_cached(account_id, key, params, charge)
    return charge
```

```text
// Server crashes after `db.insert_charge` but before `webhook_queue.enqueue`.
// Charge exists, webhook never fires; downstream systems don't know.
// Retry runs the WHOLE function — `card_network.authorize` runs again → second card auth.
// `db.insert_charge` violates unique constraint or creates a duplicate row.
```

**Correct (recovery-point pattern — resume from where you crashed):**

```python
def post_charge(account_id, key, params):
    record = upsert_idempotency_record(account_id, key, params)
    if record.recovery_point == 'finished':
        return record.response  # standard idempotent replay

    if record.recovery_point == 'started':
        auth = card_network.authorize_idempotent(params, key)  # network-level dedup
        record = update_recovery_point(record, 'card_authorized', {'auth': auth})

    if record.recovery_point == 'card_authorized':
        charge = db.insert_charge_idempotent(params, record.data.auth, key)
        record = update_recovery_point(record, 'charge_persisted', {'charge': charge})

    if record.recovery_point == 'charge_persisted':
        webhook_queue.enqueue_idempotent('charge.created', record.data.charge, key)
        record = update_recovery_point(record, 'webhook_enqueued')

    if record.recovery_point == 'webhook_enqueued':
        balance_service.update(account_id, record.data.charge.amount, key)
        record = update_recovery_point(record, 'finished', response=record.data.charge)

    return record.response
```

```text
// Crash between any two phases? Retry resumes from the recorded recovery point.
// Each step uses the idempotency key for downstream dedup (card network, DB, queue).
// Customer is never double-charged; webhooks always fire eventually.
```

**Each foreign mutation gets its own atomic phase boundary.** The rule is: write the recovery point only after the foreign side effect is durable. Don't bundle multiple foreign mutations into one phase — if you crash mid-phase, you re-execute the foreign mutation.

**Downstream services accept the same idempotency key** for their own deduplication. This is the recursive part of the pattern: the charge service passes the key to the card network, the DB insert, the webhook queue. Each layer dedupes independently using the same key.

**The recovery-point state machine is per-endpoint** and lives alongside the request hash. Add columns to the idempotency record:

```sql
ALTER TABLE idempotent_responses
  ADD COLUMN recovery_point VARCHAR(64) NOT NULL DEFAULT 'started',
  ADD COLUMN recovery_data JSONB NOT NULL DEFAULT '{}'::jsonb,
  ADD COLUMN locked_at TIMESTAMPTZ,
  ADD COLUMN lock_holder VARCHAR(255);
```

**Hold a lock for the duration of a request to prevent concurrent execution** of the same key — two parallel retries shouldn't both advance the state machine. Use `SELECT ... FOR UPDATE` or a separate lock column with a TTL.

**When NOT to use recovery points:** for genuinely atomic single-step operations (`POST /v1/customers` that just inserts a row). The pattern is for operations with multiple foreign side effects.

Reference: [Brandur — implementing Stripe-like idempotency keys](https://brandur.org/idempotency-keys)
