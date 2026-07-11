---
title: Read ZodError.issues — the .errors getter is removed
tags: gone, error-handling, removed-api
---

## Read ZodError.issues — the .errors getter is removed

The wrong default is iterating `error.errors`, the Zod 3 alias getter. zod@4 removed it; the canonical array is `error.issues`. Because ZodError values often travel through `catch (e)` blocks typed `unknown` or `any`, this read frequently survives tsc and surfaces as `undefined.map is not a function` at runtime — in the error path, where tests are thinnest.

**Evidence of violation:** `.errors` accessed on a value that is a ZodError — the `error` of a `safeParse` result, or a variable narrowed by `instanceof ZodError` / `z.ZodError`.

**Incorrect (removed getter — undefined at runtime when the error is untyped):**

```ts
const result = SignupSchema.safeParse(body)
if (!result.success) {
  return json({ messages: result.error.errors.map((e) => e.message) }, 400)
}
```

**Correct (issues is the canonical array):**

```ts
const result = SignupSchema.safeParse(body)
if (!result.success) {
  return json({ messages: result.error.issues.map((issue) => issue.message) }, 400)
}
```

Reference: [Zod 4 changelog — ZodError changes](https://zod.dev/v4/changelog)
