---
title: Replace required_error/invalid_type_error/errorMap with the error function
tags: gone, error-customization, removed-api
---

## Replace required_error/invalid_type_error/errorMap with the error function

The wrong default is the Zod 3 params trio — `required_error`, `invalid_type_error`, and `errorMap` — which models reproduce verbatim from years of training data. All three were **removed** in zod@4.0 in favor of a single `error` param that accepts a string or a function over the issue. The function form covers everything the trio did: branch on `iss.input === undefined` for the required case, on issue code for type errors, and return `undefined` to defer to the default message.

**Evidence of violation:** `required_error:`, `invalid_type_error:`, or `errorMap:` inside a Zod schema's params object; `ctx.defaultError` inside a former error map.

**Incorrect (removed in 4.0 — the params are no longer accepted):**

```ts
const Amount = z.number({
  required_error: "Amount is required",
  invalid_type_error: "Amount must be a number",
})
```

**Correct (one error function branches on the issue):**

```ts
const Amount = z.number({
  error: (iss) => (iss.input === undefined ? "Amount is required" : "Amount must be a number"),
})
```

For app-wide customization, `z.config({ customError: ... })` replaces `z.setErrorMap()`. Note the precedence change: a schema-level `error` now beats a per-parse `error`.

Reference: [Zod — error customization](https://zod.dev/error-customization)
