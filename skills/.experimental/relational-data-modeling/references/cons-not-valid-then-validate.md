---
title: Add constraints to live tables NOT VALID, then VALIDATE
tags: cons, migration, locking, schema-evolution
---

## Add constraints to live tables NOT VALID, then VALIDATE

A plain `ALTER TABLE ... ADD CONSTRAINT` scans the entire table to prove the
constraint holds, and holds a lock for the whole scan. How bad that is depends
on the constraint: `ADD FOREIGN KEY` takes `SHARE ROW EXCLUSIVE` on both tables,
which blocks writes but not reads; `ADD CHECK` and `SET NOT NULL` take
`ACCESS EXCLUSIVE`, which blocks reads too — and blocks them behind a queue that
stalls every query arriving after it. On a table large enough to care about,
that second kind is the migration that takes the site down. It is also the
reason teams stop adding constraints to mature schemas at all, which is how
invariants drift into application code.

`NOT VALID` splits the operation. Adding the constraint skips the scan and takes
only a brief lock, and — the part that matters — **the constraint is enforced
against all subsequent inserts and updates immediately**. Only the assertion
about pre-existing rows is deferred. `VALIDATE CONSTRAINT` then performs the
scan under a `SHARE UPDATE EXCLUSIVE` lock, which does not block concurrent
readers or writers, because the database already knows new rows are being
checked.

```sql
-- Step 1: cheap lock, no scan; every new row is checked from this moment.
ALTER TABLE support_tickets
    ADD CONSTRAINT support_ticket_customer_fk
    FOREIGN KEY (customer_id) REFERENCES customers
    NOT VALID;

-- Step 2 (separate transaction): scan the backlog without blocking traffic.
ALTER TABLE support_tickets VALIDATE CONSTRAINT support_ticket_customer_fk;
```

Run the two steps as separate transactions, and fix any rows the validation
rejects in between — that gap is the point of the split, not a flaw in it.

`NOT VALID` is available for foreign-key, `CHECK`, and not-null constraints;
PostgreSQL 18 added the not-null case, which previously required a full-table
scan under `ACCESS EXCLUSIVE`. It is *not* available for `UNIQUE` or `EXCLUDE`,
because both are backed by an index. Build those concurrently instead, then
attach:

```sql
CREATE UNIQUE INDEX CONCURRENTLY customer_email_uk ON customers (email);
ALTER TABLE customers ADD CONSTRAINT customer_email_uk UNIQUE USING INDEX customer_email_uk;
```

Do not confuse `NOT VALID` with PostgreSQL 18's new `NOT ENFORCED`. They sound
similar and do opposite things: `NOT VALID` skips the backlog but enforces every
new row, whereas `NOT ENFORCED` declares a constraint the database never checks
at all — `CHECK (amount > 0) NOT ENFORCED` accepts `-5` without complaint. It
exists to document a rule an external system guarantees; used by mistake it is
a constraint-shaped comment.

This rule is what makes the rest of this category affordable. A schema whose
constraints can only be added at creation time will accumulate invariants that
live nowhere but a code review comment.

Reference: [PostgreSQL 18 — ALTER TABLE](https://www.postgresql.org/docs/18/sql-altertable.html), [PostgreSQL 18 Release Notes](https://www.postgresql.org/docs/release/18.0/)
