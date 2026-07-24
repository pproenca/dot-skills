---
title: Apply concurrent index builds outside the migrator
tags: migrate, indexes, concurrently, locks
---

## Apply concurrent index builds outside the migrator

Adding an index to a live table with a plain `CREATE INDEX` takes a lock that blocks every write to that table until the build finishes — minutes of downtime on a large table. `CREATE INDEX CONCURRENTLY` exists to avoid that, and Drizzle exposes it as `.concurrently()`. The two facts that collide: Postgres forbids `CREATE INDEX CONCURRENTLY` inside a transaction block, and Drizzle's `migrate()` wraps *all* pending migration files in a single transaction. So the statement generated to avoid downtime fails at apply time with `CREATE INDEX CONCURRENTLY cannot run inside a transaction block` — a failure that only appears against a real database, never during `generate`.

```typescript
// lib/db/schema.ts — declare it so drizzle-kit emits the CONCURRENTLY form
export const invoices = pgTable(
  'invoices',
  { /* ... */ },
  // `.concurrently()` chains after `.on()` — it lives on the built index, not the builder.
  (t) => [index('invoices_org_issued_at_idx').on(t.organizationId, t.issuedAt).concurrently()],
)
```

```bash
# Move the generated statement out of the transactional migration file and
# apply it on its own connection, outside the migrator.
psql "$DATABASE_URL" -c "CREATE INDEX CONCURRENTLY IF NOT EXISTS invoices_org_issued_at_idx ON invoices (organization_id, issued_at);"

# Then let the migrator run the rest.
npx drizzle-kit migrate
```

A concurrent build that is interrupted leaves an `INVALID` index behind, which still costs write overhead but is never used for reads. Check `pg_index.indisvalid` after a failed deploy and `DROP INDEX` before retrying — this is why `IF NOT EXISTS` alone is not a sufficient guard.

Reference: [PostgreSQL — CREATE INDEX, Building Indexes Concurrently](https://www.postgresql.org/docs/current/sql-createindex.html#SQL-CREATEINDEX-CONCURRENTLY) · `drizzle-orm@0.45.2/pg-core/dialect.js` (`migrate()` wraps all pending files in `session.transaction`)
