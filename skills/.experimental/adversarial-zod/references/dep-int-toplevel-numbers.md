---
title: Use z.int() and fixed-width number schemas — z.number().int() is deprecated
tags: dep, numbers, deprecated-api
---

## Use z.int() and fixed-width number schemas — z.number().int() is deprecated

The wrong default is `z.number().int()` (and `.safe()`), Zod 3's integer spelling. zod@4 provides `z.int()` — which enforces the safe-integer range — plus fixed-width variants (`z.int32()`, `z.uint32()`, `z.float32()`, `z.float64()`, and bigint-based `z.int64()`/`z.uint64()`). Two behavior notes ride along: `z.number()` no longer accepts `Infinity`/`-Infinity` (finite is the default, making `.finite()` a no-op relic), and integer checks now reject unsafe integers.

**Evidence of violation:** `z.number().int(`, `.safe(`, or `.finite(` chained on a Zod number schema.

**Incorrect (deprecated method forms):**

```ts
const Pagination = z.object({
  page: z.number().int().positive(),
  perPage: z.number().int().max(100),
})
```

**Correct (top-level integer schema):**

```ts
const Pagination = z.object({
  page: z.int().positive(),
  perPage: z.int().max(100),
})
```

Reference: [Zod 4 changelog — number changes](https://zod.dev/v4/changelog), [Zod API — numbers](https://zod.dev/api)
