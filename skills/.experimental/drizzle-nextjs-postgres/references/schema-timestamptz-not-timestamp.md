---
title: Declare timestamps with withTimezone
tags: schema, timestamp, timestamptz, dates
---

## Declare timestamps with withTimezone

`timestamp('created_at')` compiles to `timestamp without time zone`, which is not a point in time — it is a wall-clock reading with no offset attached, so Postgres cannot tell you whether two rows written from different regions describe the same instant. It survives testing because a single-region deployment reading and writing in UTC round-trips consistently; it breaks at the first daylight-saving boundary, the first user in another timezone, or the first interval arithmetic. `timestamptz` stores an absolute instant and converts on input and output, which is what application code assumes it is getting when it reads a `Date`.

```typescript
import { pgTable, text, integer, timestamp } from 'drizzle-orm/pg-core'

export const invoices = pgTable('invoices', {
  id: integer().primaryKey().generatedAlwaysAsIdentity(),
  reference: text().notNull().unique(),
  issuedAt: timestamp({ withTimezone: true }).notNull().defaultNow(),
  updatedAt: timestamp({ withTimezone: true })
    .notNull()
    .defaultNow()
    .$onUpdate(() => new Date()),
})
```

The default `mode: 'date'` gives a JS `Date`; `mode: 'string'` hands back the raw Postgres text and is worth choosing only when you need the exact stored representation. Note that `$onUpdate` is applied by Drizzle when it builds the `UPDATE`, so a write issued outside Drizzle will not touch `updatedAt` — use a database trigger if you need that guarantee.

Reference: [PostgreSQL Wiki — Don't Do This: timestamp vs timestamptz](https://wiki.postgresql.org/wiki/Don%27t_Do_This#Don.27t_use_timestamp_.28without_time_zone.29) · [Drizzle — PostgreSQL column types](https://orm.drizzle.team/docs/column-types/pg)
