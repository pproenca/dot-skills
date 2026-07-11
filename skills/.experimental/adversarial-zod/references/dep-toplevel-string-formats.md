---
title: Use top-level string formats — z.email(), z.url(), z.uuid(), z.iso.datetime()
tags: dep, string-formats, deprecated-api
---

## Use top-level string formats — z.email(), z.url(), z.uuid(), z.iso.datetime()

The wrong default is the Zod 3 method chain: `z.string().email()`, `.url()`, `.uuid()`, `.datetime()`, and the rest of the format family. zod@4 promoted formats to first-class top-level schemas — `z.email()`, `z.url()`, `z.uuid()` (plus `z.uuidv4()`/`z.uuidv7()`), `z.iso.datetime()`, `z.iso.date()`, `z.iso.time()`, `z.iso.duration()`, `z.base64()`, `z.nanoid()`, `z.cuid2()`, `z.ulid()` — which are tree-shakable and carry stricter, spec-conformant validation. The method forms are deprecated and will be removed in the next major, so every new occurrence is future migration work.

**Evidence of violation:** `.email(`, `.url(`, `.uuid(`, `.emoji(`, `.nanoid(`, `.cuid(`, `.cuid2(`, `.ulid(`, `.base64(`, `.base64url(`, `.datetime(`, `.date(`, `.time(`, or `.duration(` chained on `z.string()`.

**Incorrect (deprecated method forms):**

```ts
const Invite = z.object({
  email: z.string().email(),
  redirectUrl: z.string().url(),
  invitedAt: z.string().datetime(),
})
```

**Correct (top-level format schemas):**

```ts
const Invite = z.object({
  email: z.email(),
  redirectUrl: z.url(),
  invitedAt: z.iso.datetime(),
})
```

Constraint methods that are not formats (`.min()`, `.max()`, `.regex()`, `.trim()`, ...) are unchanged and chain on the new schemas as before.

Reference: [Zod 4 changelog — deprecated string methods](https://zod.dev/v4/changelog), [Zod API — string formats](https://zod.dev/api)
