---
title: Pass schema to drizzle() or db.query is empty
tags: conn, relational-queries, schema, relations
---

## Pass schema to drizzle() or db.query is empty

`drizzle(process.env.DATABASE_URL!)` is the documented one-liner and it produces a working client — for `db.select()` only. The relational query builder is generated from the schema object handed to the constructor, so without it `db.query` has no keys at all and `db.query.invoices.findMany(...)` fails with a type error that reads like a missing table rather than a missing config. The second half of the same trap: `db.query.x.findMany({ with: { y: true } })` only sees relationships declared in a `relations()` call. Foreign keys declared with `.references()` constrain the database; they do not tell the query builder how to traverse.

```typescript
// lib/db/schema.ts
import { relations } from 'drizzle-orm'
import { pgTable, text, integer, timestamp } from 'drizzle-orm/pg-core'

export const customers = pgTable('customers', {
  id: integer().primaryKey().generatedAlwaysAsIdentity(),
  email: text().notNull().unique(),
})

export const invoices = pgTable('invoices', {
  id: integer().primaryKey().generatedAlwaysAsIdentity(),
  customerId: integer().notNull().references(() => customers.id, { onDelete: 'cascade' }),
  issuedAt: timestamp({ withTimezone: true }).notNull().defaultNow(),
})

export const customersRelations = relations(customers, ({ many }) => ({
  invoices: many(invoices),
}))

export const invoicesRelations = relations(invoices, ({ one }) => ({
  customer: one(customers, { fields: [invoices.customerId], references: [customers.id] }),
}))
```

```typescript
// lib/db/index.ts — schema must include the relations exports, so use a namespace import
import * as schema from './schema'
export const db = drizzle(process.env.DATABASE_URL!, { schema })

// Now this compiles and issues one statement instead of an N+1 loop.
const withInvoices = await db.query.customers.findMany({
  columns: { id: true, email: true },
  with: { invoices: { columns: { id: true, issuedAt: true }, limit: 10 } },
})
```

Reference: [Drizzle — Relational Queries](https://orm.drizzle.team/docs/rqb) · [Drizzle — Relations](https://orm.drizzle.team/docs/relations)
