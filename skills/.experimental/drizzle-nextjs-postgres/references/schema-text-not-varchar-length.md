---
title: Use text unless a length limit is a real business rule
tags: schema, text, varchar, constraints
---

## Use text unless a length limit is a real business rule

`varchar({ length: 255 })` is a habit carried over from MySQL, where it affected storage. In Postgres `varchar(n)` and `text` are the same type with the same performance; the only difference is a length check. So the number is pure downside unless it encodes something true: 255 is not a fact about email addresses, and the day a real one exceeds it the insert fails in production. Worse, widening the limit later is a schema migration, whereas a `CHECK` constraint expresses the same rule and can be altered without touching the column type.

```typescript
import { pgTable, text, integer, char, check } from 'drizzle-orm/pg-core'
import { sql } from 'drizzle-orm'

export const customers = pgTable(
  'customers',
  {
    id: integer().primaryKey().generatedAlwaysAsIdentity(),
    email: text().notNull().unique(),
    displayName: text().notNull(),
    // A genuine fixed width from the spec — ISO 4217 — not a guess.
    currency: char({ length: 3 }).notNull(),
  },
  (t) => [check('display_name_length', sql`length(${t.displayName}) <= 80`)],
)
```

`varchar({ length: n })` is right when `n` comes from an external specification or an integration's documented limit. It is wrong when it comes from picking a round number.

Reference: [PostgreSQL Wiki — Don't Do This: varchar(n)](https://wiki.postgresql.org/wiki/Don%27t_Do_This#Don.27t_use_varchar.28n.29_by_default) · [PostgreSQL — Character Types](https://www.postgresql.org/docs/current/datatype-character.html)
