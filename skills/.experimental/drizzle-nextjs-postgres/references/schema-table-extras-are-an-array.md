---
title: Return an array from the third pgTable argument
tags: schema, indexes, deprecation, table-config
---

## Return an array from the third pgTable argument

Most Drizzle examples in circulation return an object from the third `pgTable` argument — `(t) => ({ emailIdx: index(...).on(t.email) })` — because that was the API for years. It is deprecated in current Drizzle: the keys were never used for anything, and the object form is retained only for backward compatibility. Writing it is marked `@deprecated` in Drizzle's own type definitions — an editor strikethrough and lint signal rather than a runtime error — on code that will need editing at the next major. The array form is the current signature and reads better anyway, since the entries were always an unordered set of constraints rather than a named map.

```typescript
import { pgTable, integer, text, timestamp, index, uniqueIndex } from 'drizzle-orm/pg-core'

export const invoices = pgTable(
  'invoices',
  {
    id: integer().primaryKey().generatedAlwaysAsIdentity(),
    organizationId: integer().notNull().references(() => organizations.id, { onDelete: 'cascade' }),
    reference: text().notNull(),
    issuedAt: timestamp({ withTimezone: true }).notNull().defaultNow(),
  },
  (t) => [
    // Postgres does not index foreign keys automatically — every unindexed FK
    // turns a parent DELETE into a sequential scan of this table.
    index('invoices_organization_id_idx').on(t.organizationId),
    uniqueIndex('invoices_org_reference_idx').on(t.organizationId, t.reference),
    index('invoices_org_issued_at_idx').on(t.organizationId, t.issuedAt.desc()),
  ],
)
```

The composite index ordering matters as much as the array syntax: Postgres can use a leading subset of an index's columns, so `(organizationId, issuedAt)` also serves lookups by `organizationId` alone, while `(issuedAt, organizationId)` does not.

Reference: `drizzle-orm@0.45.2/pg-core/table.d.ts` (the `@deprecated` note on the object overload) · [Drizzle — Indexes & Constraints](https://orm.drizzle.team/docs/indexes-constraints)
