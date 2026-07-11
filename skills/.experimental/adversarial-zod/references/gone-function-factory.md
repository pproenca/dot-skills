---
title: Treat z.function() as a factory — .args()/.returns() are removed
tags: gone, functions, removed-api
---

## Treat z.function() as a factory — .args()/.returns() are removed

The wrong default is the Zod 3 shape: `z.function().args(...).returns(...)` used as a schema, sometimes embedded inside `z.object()`. In zod@4, `z.function()` is no longer a `ZodType` at all — it is a **function factory** configured with `{ input, output }`, and it wraps implementations via `.implement()` / `.implementAsync()` so arguments and return values are validated on every call. `.args()`/`.returns()` were removed, and a `z.function()` nested in another schema no longer works — use `z.custom<Fn>()` to type a function-valued property.

**Evidence of violation:** `z.function().args(` or `z.function().returns(`; or `z.function(` appearing inside another schema (`z.object`, `z.record`, ...).

**Incorrect (removed API, and no longer a schema):**

```ts
const HandlerSchema = z.function().args(z.string()).returns(z.number())

const Plugin = z.object({
  name: z.string(),
  onEvent: z.function(), // not a ZodType in v4
})
```

**Correct (factory + implement; z.custom for function props):**

```ts
const measure = z.function({ input: [z.string()], output: z.number() })
export const wordCount = measure.implement((text) => text.split(/\s+/).length)

const Plugin = z.object({
  name: z.string(),
  onEvent: z.custom<(event: string) => void>((v) => typeof v === "function"),
})
```

Reference: [Zod API — functions](https://zod.dev/api), [Zod 4 changelog](https://zod.dev/v4/changelog)
