---
title: Pick the bigint mode that matches the range you actually store
tags: schema, bigint, precision, type-inference
---

## Pick the bigint mode that matches the range you actually store

`bigint()` requires an explicit `mode`, and the ergonomic choice is the dangerous one. `mode: 'number'` infers as `number`, which is what surrounding code wants — but a JS number is a double, exact only to 2^53−1, while Postgres `bigint` goes to 2^63−1. Values above the safe range come back silently rounded: no error, no warning, just an id that no longer matches the row it came from. `mode: 'bigint'` infers as the `BigInt` primitive and is exact across the whole range, at the cost of not being JSON-serializable without an explicit conversion.

```typescript
import { pgTable, bigint, integer, timestamp } from 'drizzle-orm/pg-core'

export const ledgerEntries = pgTable('ledger_entries', {
  id: integer().primaryKey().generatedAlwaysAsIdentity(),
  // Externally-issued identifiers can exceed 2^53 — exactness is required.
  providerTransactionId: bigint({ mode: 'bigint' }).notNull().unique(),
  // Bounded by our own row counts; 'number' is safe and more ergonomic.
  sequenceNumber: bigint({ mode: 'number' }).notNull(),
  recordedAt: timestamp({ withTimezone: true }).notNull().defaultNow(),
})
```

`mode: 'number'` is fine when the value's range is bounded by something you control. It is wrong for anything issued by an external system — Twitter-style snowflake ids, Stripe object counters, blockchain block numbers — where 2^53 is a plausible magnitude. `BigInt` values passed to a Client Component must be converted first, since React's serialization does not carry them.

Reference: [Drizzle — PostgreSQL column types: bigint](https://orm.drizzle.team/docs/column-types/pg#bigint) · [PostgreSQL — Numeric Types](https://www.postgresql.org/docs/current/datatype-numeric.html)
