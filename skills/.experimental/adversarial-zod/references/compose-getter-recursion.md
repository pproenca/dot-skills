---
title: Write recursive schemas with getters, not z.lazy plus manual annotations
tags: compose, recursion, type-inference
---

## Write recursive schemas with getters, not z.lazy plus manual annotations

The wrong default is the Zod 3 recursion dance: declare the TypeScript type by hand, annotate the schema `z.ZodType<T>`, and wrap the self-reference in `z.lazy()`. In zod@4 a getter on plain `z.object()` resolves the cycle with **full inference** — no hand-written type to drift out of sync, and none of the annotation's side effects (a `z.ZodType`-typed schema loses its object methods, so `.extend()`/`.omit()`/`.pick()` stop working on it).

**Evidence of violation:** a schema variable annotated `z.ZodType<...>` (or `ZodSchema<...>`) whose definition contains `z.lazy(() => ...)` referring back to itself or to a mutually recursive sibling.

**Incorrect (manual annotation — type drift risk, loses object methods):**

```ts
type Category = { name: string; subcategories: Category[] }

const Category: z.ZodType<Category> = z.object({
  name: z.string(),
  subcategories: z.lazy(() => z.array(Category)),
})
```

**Correct (getter recursion, fully inferred):**

```ts
const Category = z.object({
  name: z.string(),
  get subcategories() { return z.array(Category) },
})

type Category = z.infer<typeof Category>
```

`z.lazy()` itself is not deprecated — deferring an expensive schema is still legitimate. The violation is specifically the annotation-plus-lazy pattern for recursion.

Reference: [Zod API — recursive objects](https://zod.dev/api)
