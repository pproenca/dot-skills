---
title: Model auditable facts as immutable events and derive the state
tags: time, event-sourcing, ledger, append-only
---

## Model auditable facts as immutable events and derive the state

`accounts.balance` updated in place is the shape that comes out by default, and
it destroys information that cannot be recovered. The row records that the
balance is 4,200; it does not record that it was 4,700 an hour ago, which
transaction moved it, whether the move was a payment or a correction, or who
authorised it. When the number is disputed — and for money, inventory, or
credits it eventually is — there is nothing to reconcile against. The row is also
a contention point: every concurrent operation on that account must serialise
behind a lock on one tuple, so throughput is bounded by the hottest account.

Recording the change instead of the result fixes both. Appends do not contend for
a row lock the way a shared counter does, so concurrent movements on one account
no longer serialise behind each other, and the balance becomes a derivation you
can recompute from scratch — which is what makes reconciliation possible at all.
(Contention does not vanish entirely: a unique index still arbitrates, and any
invariant over the *running* balance, such as "never overdraw", reintroduces
serialisation — see the last section and
[`norm-derived-needs-a-mechanism`](norm-derived-needs-a-mechanism.md).)

```sql
CREATE TABLE ledger_entries (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    account_id  bigint NOT NULL REFERENCES accounts,
    -- Signed minor units. A withdrawal is a negative entry, not an UPDATE.
    amount      bigint NOT NULL CHECK (amount <> 0),
    currency    text   NOT NULL REFERENCES currencies (code),
    -- What caused this, so the entry can be explained and deduplicated.
    reason      text   NOT NULL,
    external_ref text  NOT NULL,
    occurred_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (account_id, external_ref)
);

CREATE INDEX ON ledger_entries (account_id, occurred_at);
```

The `UNIQUE (account_id, external_ref)` is doing real work: it makes the write
idempotent, so a retried request that already succeeded is rejected by the
database rather than double-counted. In-place updates have no equivalent —
`balance = balance - 50` applied twice is simply wrong, with no trace.

Double-entry goes one step further and records both sides of every movement, so
"the entries for this transfer sum to zero" becomes a checkable property of the
data. That is worth the extra rows whenever money crosses a boundary between
accounts you both control.

Derive the balance rather than storing it, and when the derivation gets too slow,
add a checkpoint — a periodic snapshot row of the balance as of an instant — so
current balance is that snapshot plus the entries after it. Both remain
recomputable, which is the property in-place updates give up.

**When NOT to use this pattern:** most tables are not ledgers. A user's display
name, a draft document, a UI preference — updating these in place is correct, and
event-sourcing them buys an audit trail nobody will read at the cost of every
read becoming a fold. Apply this where a wrong number costs money or has to be
defended to somebody: balances, inventory, entitlements, quota consumption.

Reference: [Fowler — Accounting Patterns: Accounting Entry](https://martinfowler.com/eaaDev/AccountingEntry.html), [Fowler — Event Sourcing](https://martinfowler.com/eaaDev/EventSourcing.html)
