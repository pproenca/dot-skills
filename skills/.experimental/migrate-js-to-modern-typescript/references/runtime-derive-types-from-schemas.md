---
title: Derive Static Types from Runtime Schemas
impact: MEDIUM
impactDescription: maintains runtime and compile-time type sync
tags: runtime, schemas, inference, single-source
---

## Derive Static Types from Runtime Schemas

Declaring an `interface` and a separate validator for the same data creates two sources of truth that drift apart — the schema accepts a field the interface forgot, or vice versa, and the mismatch only shows up in production. Define the schema once and infer the static type from it (`z.infer`), so the runtime check and the compile-time type can never disagree.

**Incorrect (interface and validator declared separately):**

```typescript
interface Order {
  id: string
  total: number
}

// The schema and the interface drift: add `currency` to one and the other
// silently disagrees, with no compile error.
const OrderSchema = z.object({ id: z.string(), total: z.number() })
```

**Correct (one schema, type inferred from it):**

```typescript
import { z } from "zod"

const OrderSchema = z.object({
  id: z.string(),
  total: z.number(),
  currency: z.enum(["usd", "eur"]),
})

type Order = z.infer<typeof OrderSchema> // always matches the validator
```

Reference: [Zod: Type Inference](https://zod.dev/basics)
