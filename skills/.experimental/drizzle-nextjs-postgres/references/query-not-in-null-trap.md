---
title: Use notExists instead of NOT IN over a nullable subquery
tags: query, null, not-in, anti-join
---

## Use notExists instead of NOT IN over a nullable subquery

`NOT IN (subquery)` reads as set subtraction and behaves as three-valued logic. If the subquery returns even one NULL, every comparison evaluates to `UNKNOWN` rather than `TRUE`, the `WHERE` clause matches nothing, and the query returns an empty set — no error, no warning. This is a silent-wrong-answer bug that survives every test written against data where the column happened to be fully populated, and appears the first time one row has a NULL. `NOT EXISTS` uses ordinary existence semantics, is immune to the NULL case, and lets the planner choose an anti-join instead of the quadratic evaluation `NOT IN` can degrade into.

**Incorrect (one NULL `invoice_id` in `payments` makes this return nothing):**

```typescript
import { notInArray } from 'drizzle-orm'

const unpaid = await db
  .select()
  .from(invoices)
  .where(notInArray(invoices.id, db.select({ id: payments.invoiceId }).from(payments)))
```

**Correct (NULL-safe and plans as an anti-join):**

```typescript
import { notExists, eq } from 'drizzle-orm'

const unpaid = await db
  .select()
  .from(invoices)
  .where(
    notExists(
      db.select({ one: sql`1` }).from(payments).where(eq(payments.invoiceId, invoices.id)),
    ),
  )
```

`notInArray` against a literal JavaScript array you built yourself is fine — you know whether it contains null. The trap is specifically a subquery over a nullable column.

Reference: [PostgreSQL Wiki — Don't Do This: NOT IN](https://wiki.postgresql.org/wiki/Don%27t_Do_This#Don.27t_use_NOT_IN) · [PostgreSQL — Subquery Expressions](https://www.postgresql.org/docs/current/functions-subquery.html)
