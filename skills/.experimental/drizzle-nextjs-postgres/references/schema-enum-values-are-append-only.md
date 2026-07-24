---
title: Treat pgEnum as append-only, and never backfill with a new value in the same migration
tags: schema, pg-enum, migrations, check-constraint
---

## Treat pgEnum as append-only, and never backfill with a new value in the same migration

`pgEnum` looks like a TypeScript union that happens to live in the database, so values get added and removed as freely as union members. Postgres does not work that way: `ALTER TYPE ... ADD VALUE` and `RENAME VALUE` exist, but there is no way to remove a value — dropping one means recreating the type and rewriting every column that uses it. There is a sharper trap on the way in, too. `ADD VALUE` may run inside a transaction block, but the new value **cannot be used until that transaction commits** — and Drizzle's `migrate()` runs every pending migration file inside one transaction. So a migration that adds `'refunded'` and then updates rows to `'refunded'` fails at apply time, having passed every local `push`.

```typescript
import { pgTable, pgEnum, integer, text } from 'drizzle-orm/pg-core'

// Stable, closed set — the state machine's states. Adding is cheap, removing is not.
export const invoiceStatus = pgEnum('invoice_status', ['draft', 'issued', 'paid', 'void'])

export const invoices = pgTable('invoices', {
  id: integer().primaryKey().generatedAlwaysAsIdentity(),
  status: invoiceStatus().notNull().default('draft'),
})
```

Split the change across two migration files when a new value must be backfilled: one that only runs `ADD VALUE`, and a later one that uses it. For sets that churn — categories, tags, feature names — prefer `text()` with a `CHECK` constraint, which can be altered in a single transaction with no type rewrite.

Reference: [PostgreSQL — ALTER TYPE, Notes](https://www.postgresql.org/docs/current/sql-altertype.html) · [Drizzle — PostgreSQL enums](https://orm.drizzle.team/docs/column-types/pg#enum)
