---
title: Use z.stringbool() for string-encoded boolean flags
tags: sem, coercion, env-vars, runtime-behavior
---

## Use z.stringbool() for string-encoded boolean flags

The wrong default is `z.coerce.boolean()` for env vars, search params, or form fields that carry `"true"`/`"false"` strings. Coercion is `Boolean(input)` — plain JavaScript truthiness — so the string `"false"` coerces to `true`, and a feature flag reads as enabled when it is explicitly disabled. zod@4 added `z.stringbool()` for exactly this: it maps a configurable set of truthy strings (`"true"`, `"1"`, `"yes"`, `"on"`, ...) and falsy strings (`"false"`, `"0"`, `"no"`, `"off"`, ...) case-insensitively, and rejects anything else.

**Evidence of violation:** `z.coerce.boolean()` applied to a value that arrives as a string — `process.env.*`, URL search params, `FormData` fields, or any schema whose input is documented/typed as string.

**Incorrect (truthiness — "false" becomes true):**

```ts
const Env = z.object({
  ENABLE_BILLING: z.coerce.boolean(), // "false" → true
})

Env.parse({ ENABLE_BILLING: "false" }).ENABLE_BILLING // true — flag misread
```

**Correct (stringbool parses the string vocabulary):**

```ts
const Env = z.object({
  ENABLE_BILLING: z.stringbool(), // "false" → false, "off" → false, "1" → true
})

Env.parse({ ENABLE_BILLING: "false" }).ENABLE_BILLING // false
```

`z.coerce.boolean()` stays legitimate for genuinely truthy/falsy inputs (numbers, nullables) — the violation is applying it to string-encoded flags.

Reference: [Zod API — z.stringbool()](https://zod.dev/api)
