---
title: Add constraints NOT VALID, then validate in a second step
tags: migrate, constraints, locks, foreign-keys
---

## Add constraints NOT VALID, then validate in a second step

`drizzle-kit` generates the straightforward `ALTER TABLE ... ADD CONSTRAINT`, which is correct SQL and a bad deployment on a large table. Postgres verifies the constraint against every existing row before committing, and it holds a lock that blocks concurrent updates for the whole scan — minutes on a table with tens of millions of rows, during which writes queue and the app times out. `NOT VALID` splits the work: the constraint is added immediately without a scan and is enforced for all *new* rows from that moment, then `VALIDATE CONSTRAINT` checks the existing ones under a `SHARE UPDATE EXCLUSIVE` lock that permits concurrent reads and writes.

```sql
-- drizzle/0008_add_invoice_org_fk.sql — hand-edited after `drizzle-kit generate`

-- Fails fast rather than queueing behind a long-running query and holding
-- the lock while everything else piles up behind it.
SET lock_timeout = '3s';

ALTER TABLE invoices
  ADD CONSTRAINT invoices_organization_id_fk
  FOREIGN KEY (organization_id) REFERENCES organizations(id)
  ON DELETE CASCADE
  NOT VALID;
```

```sql
-- drizzle/0009_validate_invoice_org_fk.sql — a separate file, deployed after
ALTER TABLE invoices VALIDATE CONSTRAINT invoices_organization_id_fk;
```

The same `NOT VALID` split applies directly to `CHECK` and foreign-key constraints. A `NOT NULL` requirement needs one extra hop before Postgres 18, where `SET NOT NULL` still scans the whole table under an `ACCESS EXCLUSIVE` lock: add a `CHECK (col IS NOT NULL) NOT VALID` constraint, `VALIDATE` it, then run `SET NOT NULL` — Postgres recognises the validated check and skips its own scan. Adding a *column* with a constant default is different and needs none of this — since Postgres 11 the default is stored in the catalog and no table rewrite occurs.

Reference: [PostgreSQL — ALTER TABLE, Notes](https://www.postgresql.org/docs/current/sql-altertable.html) · [PostgreSQL — Explicit Locking](https://www.postgresql.org/docs/current/explicit-locking.html)
