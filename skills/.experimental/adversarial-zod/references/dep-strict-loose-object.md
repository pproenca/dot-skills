---
title: Use z.strictObject()/z.looseObject() instead of .strict()/.passthrough()
tags: dep, objects, deprecated-api
---

## Use z.strictObject()/z.looseObject() instead of .strict()/.passthrough()

The wrong default is configuring unknown-key behavior by method: `z.object({...}).strict()` or `.passthrough()`. zod@4 made the variants top-level constructors — `z.strictObject({...})` and `z.looseObject({...})` — and deprecated the methods. `.strip()` is also deprecated (stripping is the default; convert an exotic object back with `z.object(Schema.shape)`), while `.nonstrict()` and `.deepPartial()` were removed outright.

**Evidence of violation:** `.strict()`, `.passthrough()`, or `.strip()` chained on an object schema (deprecated); `.nonstrict()` or `.deepPartial()` (removed — does not compile).

**Incorrect (deprecated method configuration):**

```ts
const Webhook = z.object({
  id: z.string(),
  event: z.string(),
}).passthrough()

const Credentials = z.object({
  username: z.string(),
  password: z.string(),
}).strict()
```

**Correct (top-level variants):**

```ts
const Webhook = z.looseObject({
  id: z.string(),
  event: z.string(),
})

const Credentials = z.strictObject({
  username: z.string(),
  password: z.string(),
})
```

Reference: [Zod 4 changelog — object variants](https://zod.dev/v4/changelog), [Zod API — objects](https://zod.dev/api)
