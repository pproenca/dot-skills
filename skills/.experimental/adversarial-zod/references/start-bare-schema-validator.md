---
title: Pass the Zod schema directly to .validator() on server functions
tags: start, server-functions, standard-schema, tanstack
---

## Pass the Zod schema directly to .validator() on server functions

Two stale defaults collide here. Models trained on late-2025 TanStack code write `.inputValidator()`, which the current v1 RC marks `@deprecated` in favor of `.validator()`. And models trained on pre-Standard-Schema code wrap the schema in a function — `.validator((data: unknown) => Schema.parse(data))` — which discards Zod 4's Standard Schema integration: the bare schema gives the handler its typed `{ data }`, structured ZodError propagation, and no hand-rolled parse layer to maintain.

**Evidence of violation:** `.inputValidator(` on a `createServerFn` chain; or `.validator(` whose argument is a function literal that only parses with a Zod schema (`(d) => Schema.parse(d)` and equivalents).

**Incorrect (deprecated name, redundant wrapper):**

```ts
export const createInvoice = createServerFn({ method: "POST" })
  .inputValidator((data: unknown) => InvoiceSchema.parse(data))
  .handler(async ({ data }) => db.invoices.insert(data))
```

**Correct (current name, bare schema via Standard Schema):**

```ts
export const createInvoice = createServerFn({ method: "POST" })
  .validator(InvoiceSchema)
  .handler(async ({ data }) => db.invoices.insert(data)) // data: z.infer<typeof InvoiceSchema>
```

A validator function that does more than parse (normalization, context-dependent checks) is not a violation — the evidence targets pure parse wrappers and the deprecated method name.

Reference: [TanStack Start — server functions](https://tanstack.com/start/latest/docs/framework/react/guide/server-functions)
