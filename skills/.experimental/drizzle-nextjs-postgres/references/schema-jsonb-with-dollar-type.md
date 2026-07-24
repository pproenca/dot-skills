---
title: Use jsonb and narrow it with $type
tags: schema, jsonb, json, type-inference
---

## Use jsonb and narrow it with $type

`json()` and `jsonb()` look interchangeable and are not. `json` stores the literal text you sent — whitespace, key order, duplicate keys and all — and reparses it on every read, so it cannot be indexed by content and every `->>` costs a parse. `jsonb` stores a decomposed binary form that supports GIN indexes and containment operators. The only reason to pick `json` is needing byte-exact round-tripping of the original document, which application data almost never does. Separately, both infer as `unknown`, so without `$type<>()` every read needs a cast and nothing checks that writes match the shape.

```typescript
import { pgTable, integer, jsonb, index } from 'drizzle-orm/pg-core'

type InvoiceMetadata = {
  purchaseOrder?: string
  lineItems: { sku: string; quantity: number }[]
}

export const invoices = pgTable(
  'invoices',
  {
    id: integer().primaryKey().generatedAlwaysAsIdentity(),
    metadata: jsonb().$type<InvoiceMetadata>().notNull().default({ lineItems: [] }),
  },
  (t) => [index('invoices_metadata_idx').using('gin', t.metadata)],
)
```

`$type<>()` is a compile-time assertion, not a runtime check — Postgres will accept any valid JSON. When the document comes from user input, validate it at the Server Action boundary with the same schema the type is derived from.

Reference: [PostgreSQL — JSON Types](https://www.postgresql.org/docs/current/datatype-json.html) · [Drizzle — PostgreSQL column types: jsonb](https://orm.drizzle.team/docs/column-types/pg#jsonb)
