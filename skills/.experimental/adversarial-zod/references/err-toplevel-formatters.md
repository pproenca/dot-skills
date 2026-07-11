---
title: Format errors with z.treeifyError/z.flattenError/z.prettifyError
tags: err, error-formatting, deprecated-api
---

## Format errors with z.treeifyError/z.flattenError/z.prettifyError

The wrong default is calling the Zod 3 methods `error.format()` and `error.flatten()`. zod@4 moved formatting to top-level tree-shakable functions and deprecated the methods: `z.treeifyError(err)` (nested tree, any depth), `z.flattenError(err)` (one-level `fieldErrors`/`formErrors`, flat schemas only), and `z.prettifyError(err)` (human-readable multi-line string — new capability the methods never had). The methods still run today but are scheduled for removal, and `z.formatError()` is itself deprecated in favor of `z.treeifyError()`.

**Evidence of violation:** `.format(` or `.flatten(` called on a ZodError (a `safeParse` result's `error`, or a value narrowed by `instanceof ZodError`); `z.formatError(`.

**Incorrect (deprecated ZodError methods):**

```ts
const result = ProfileSchema.safeParse(input)
if (!result.success) {
  const { fieldErrors } = result.error.flatten()
  return json({ fieldErrors }, 400)
}
```

**Correct (top-level formatters):**

```ts
const result = ProfileSchema.safeParse(input)
if (!result.success) {
  const { fieldErrors } = z.flattenError(result.error)
  return json({ fieldErrors }, 400)
}
```

Reference: [Zod — error formatting](https://zod.dev/error-formatting)
