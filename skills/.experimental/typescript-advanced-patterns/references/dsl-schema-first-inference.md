---
title: Derive Static Types from Runtime Schemas
impact: CRITICAL
impactDescription: eliminates 100% of type/runtime drift between validators and TypeScript types
tags: dsl, schema, inference, zod, valibot, library-design
---

## Derive Static Types from Runtime Schemas

When the static type and the runtime validator are declared separately, they drift the moment one changes. The fix is to make the schema the single source of truth and derive the static type from it. Zod, Valibot, and ArkType all expose this via inference helpers (`z.infer<typeof schema>`, `v.InferOutput<typeof schema>`, `typeof schema.infer`). The advanced move — what library authors must understand — is that the schema *parses* in addition to *validating*: the output type can differ from the input type (`transform`, `pipe`, `coerce`), so the inferred static type belongs at the parse boundary, not at the validate boundary.

**Incorrect (parallel declarations drift on first refactor):**

```typescript
import { z } from 'zod'

interface CreateOrder {
  customerId: string
  items: { sku: string; quantity: number }[]
  notes?: string
}

const createOrderSchema = z.object({
  customerId: z.string(),
  items: z.array(z.object({ sku: z.string(), quantity: z.number() })),
  // Forgot to add `notes` to the schema — runtime accepts orders with no notes,
  // but TS thinks the field is optional. No error surfaces.
})

function handleCreateOrder(body: unknown): CreateOrder {
  return createOrderSchema.parse(body) as CreateOrder
}
```

**Correct (schema is the source; parse output is the type):**

```typescript
import { z } from 'zod'

const createOrderSchema = z.object({
  customerId: z.string().brand<'CustomerId'>(),
  items: z.array(z.object({
    sku: z.string(),
    quantity: z.coerce.number().int().positive(),
  })),
  notes: z.string().optional(),
  createdAt: z.string().pipe(z.coerce.date()),  // input: string, output: Date
})

type CreateOrder = z.output<typeof createOrderSchema>
//   ^? { customerId: string & z.BRAND<'CustomerId'>;
//        items: { sku: string; quantity: number }[];
//        notes?: string; createdAt: Date }

function handleCreateOrder(body: unknown): CreateOrder {
  return createOrderSchema.parse(body)  // body: unknown, return: CreateOrder
}
```

Use `z.output<…>` (or `v.InferOutput`) for *parsed* values that downstream code touches, and `z.input<…>` for the *unparsed* shape the API actually accepts. Treating them as the same type is the most common schema-first mistake.

**When NOT to apply:**
- Hot inner loops where the parse cost matters — validate once at the boundary, then cast or pass the parsed value through internally.
- When the schema must be generated from external metadata (OpenAPI, Protobuf) — generate both schema and type from that source, don't hand-derive one from the other.

**Scope delta:**
- `typescript-refactor`'s `error-result-type` covers result-type modeling. This rule covers the *upstream* problem: where the type comes from in the first place. The two compose — derive the success shape from a schema, wrap it in `Ok<T>`.

Reference: [Zod Docs — Inferring Types](https://zod.dev/?id=type-inference)
