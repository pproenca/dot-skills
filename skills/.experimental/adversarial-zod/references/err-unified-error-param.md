---
title: Use the error param — message is deprecated
tags: err, error-customization, deprecated-api
---

## Use the error param — message is deprecated

The wrong default is `{ message: "..." }` on checks and schemas — the Zod 3 spelling that dominates training data. zod@4 unified all error customization under a single `error` param (string, or a function over the issue); `message` is deprecated and scheduled for removal in the next major. New code writing `message` accumulates exactly the migration debt this gate exists to stop, and it can't express what `error` can (branching on the issue, deferring with `undefined`).

**Evidence of violation:** `message:` inside the params object of a Zod schema or check call (`z.string({ message: ... })`, `.min(5, { message: ... })`, `.refine(fn, { message: ... })`).

**Incorrect (deprecated param):**

```ts
const Password = z.string()
  .min(12, { message: "Password must be at least 12 characters" })
```

**Correct (error param — or the plain-string shorthand):**

```ts
const Password = z.string()
  .min(12, { error: "Password must be at least 12 characters" })

// equivalent shorthand
const Pin = z.string().length(6, "PIN must be exactly 6 digits")
```

Reference: [Zod — error customization](https://zod.dev/error-customization)
