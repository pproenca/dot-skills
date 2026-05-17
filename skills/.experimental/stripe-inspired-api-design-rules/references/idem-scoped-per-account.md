---
title: Scope Idempotency Keys per Account, Not Globally
impact: HIGH
impactDescription: prevents key collisions across tenants in a multi-tenant API
tags: idem, scoping, multi-tenant, security
---

## Scope Idempotency Keys per Account, Not Globally

Idempotency keys are unique per `(account, key)` tuple, not globally. Two different accounts can use the same key string (`"abc123"`) without conflict — each has its own keyspace. This matters for two reasons: (1) information disclosure — globally-unique keys would let one account discover another's keys by guessing; (2) collision avoidance — integrators don't have to coordinate key generation across tenants.

The database constraint is a composite unique index: `UNIQUE (account_id, idempotency_key)`. Implementation cost is trivial; the alternative (single global keyspace) creates a class of bugs that surface only at scale when two unrelated integrators happen to choose the same key.

**Incorrect (global keyspace — accounts can collide and leak):**

```sql
CREATE TABLE idempotent_responses (
  idempotency_key VARCHAR(255) PRIMARY KEY,
  account_id VARCHAR(255) NOT NULL,
  response_body JSONB NOT NULL,
  created_at TIMESTAMPTZ NOT NULL
);
```

```text
// Account A submits key "order-123" → cached.
// Account B submits key "order-123" → either gets A's response (data leak!) or 409 (UX bug).
// Integrators have to know to namespace their keys: "acct_X-order-123" — leaks their account ID.
```

**Correct (per-account keyspace with composite unique index):**

```sql
CREATE TABLE idempotent_responses (
  account_id VARCHAR(255) NOT NULL,
  idempotency_key VARCHAR(255) NOT NULL,
  request_hash VARCHAR(64) NOT NULL,  -- for idem-fail-on-key-reuse
  response_status SMALLINT NOT NULL,
  response_body JSONB NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY (account_id, idempotency_key)
);
```

```text
// Account A's key "order-123" lives in its own keyspace.
// Account B's key "order-123" is independent — no leak, no collision.
// Integrators use natural keys (order IDs, business event IDs) without namespacing.
```

**Lookup is also scoped:**

```python
def get_cached_response(account_id: str, key: str) -> Optional[Response]:
    row = db.fetch_one(
        "SELECT response_status, response_body, request_hash "
        "FROM idempotent_responses "
        "WHERE account_id = $1 AND idempotency_key = $2",
        account_id, key
    )
    return row
```

**For Connect / platform APIs**, the scope still includes the *acting* account (the one in `Stripe-Account: acct_X`), not the platform account. A platform that operates on behalf of 1000 connected accounts has 1000 separate keyspaces, one per acted-on account. This means the same platform code can submit the same key string for two different connected accounts without conflict.

**Key uniqueness is enforced at insert time** via the unique index, not in application code. The constraint violation surfaces as the conflict path in [`idem-fail-on-key-reuse`](idem-fail-on-key-reuse.md).

**Document the scoping rule prominently** so integrators understand:

> Idempotency keys are scoped per account. The same key string may be used safely by different accounts without conflict.

Reference: [Brandur — designing idempotency keys](https://brandur.org/idempotency-keys)
