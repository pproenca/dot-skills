---
title: Store money as integer cents, and expect numeric to infer as string
tags: schema, numeric, money, decimal
---

## Store money as integer cents, and expect numeric to infer as string

Two traps sit on top of each other here. First, `numeric()` infers as `string`, not `number` — Drizzle does that deliberately, because `numeric` can hold values no IEEE-754 double can represent, so silently coercing would lose precision. Code written expecting a number compiles until someone does arithmetic and gets `"10.00" + "5.00" === "10.005.00"`. Second, reaching for `mode: 'number'` to "fix" the type reintroduces exactly the floating-point error the type existed to avoid. For money the durable answer is neither: store an integer number of minor units, so every value is exact and every sum is integer arithmetic.

```typescript
import { pgTable, integer, text, numeric, char } from 'drizzle-orm/pg-core'

export const invoices = pgTable('invoices', {
  id: integer().primaryKey().generatedAlwaysAsIdentity(),
  // Money: exact, sortable, summable, no coercion at any boundary.
  amountCents: integer().notNull(),
  currency: char({ length: 3 }).notNull(),
  // Non-money decimals where full precision matters — inferred as string.
  taxRate: numeric({ precision: 6, scale: 4 }).notNull(),
})

const [invoice] = await db.select().from(invoices).limit(1)
const taxRate = Number(invoice.taxRate) // explicit, at the edge where precision loss is acceptable
```

Postgres also ships a `money` type; it is locale-dependent and cannot represent fractions of a cent, so it is not an option worth considering. Note the same string inference applies to `bigint({ mode: 'bigint' })` — see [`schema-bigint-mode-truncation`](schema-bigint-mode-truncation.md).

Reference: [PostgreSQL Wiki — Don't Do This: money](https://wiki.postgresql.org/wiki/Don%27t_Do_This#Don.27t_use_money) · [Drizzle — PostgreSQL column types: numeric](https://orm.drizzle.team/docs/column-types/pg#numeric)
