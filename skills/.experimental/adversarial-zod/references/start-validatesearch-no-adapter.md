---
title: Pass Zod 4 schemas to validateSearch without the zod adapter
tags: start, search-params, standard-schema, tanstack
---

## Pass Zod 4 schemas to validateSearch without the zod adapter

The wrong default is the Zod 3-era route pattern: `import { zodValidator } from "@tanstack/zod-adapter"` and `validateSearch: zodValidator(searchSchema)`. Zod 4 implements Standard Schema, so TanStack Router accepts the schema directly — the adapter package exists only to bridge Zod 3's input/output-type gaps, and its `fallback` helper is superseded by Zod 4's `.catch()`. On a zod@4 project the adapter is a dead dependency adding an indirection layer that does nothing.

**Evidence of violation:** `@tanstack/zod-adapter` in `package.json` dependencies or `zodValidator(` imported/called in route files, while `package.json` pins `zod` at major 4.

**Incorrect (adapter indirection on zod@4):**

```ts
import { zodValidator } from "@tanstack/zod-adapter"

const ProductSearch = z.object({
  page: z.coerce.number().catch(1),
  sort: z.enum(["price", "rating"]).catch("price"),
})

export const Route = createFileRoute("/products")({
  validateSearch: zodValidator(ProductSearch),
})
```

**Correct (bare schema via Standard Schema, .catch() for fallbacks):**

```ts
const ProductSearch = z.object({
  page: z.coerce.number().catch(1),
  sort: z.enum(["price", "rating"]).catch("price"),
})

export const Route = createFileRoute("/products")({
  validateSearch: ProductSearch,
})
```

Reference: [TanStack Router — search params](https://tanstack.com/router/latest/docs/framework/react/guide/search-params)
