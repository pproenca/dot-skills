---
title: Chain a validator on every server function that accepts input
tags: serverfn, validation, zod, http-endpoint
---

## Chain a validator on every server function that accepts input

The wrong default is typing a server function's input with a TypeScript annotation or generic and trusting it. A server function is a public HTTP endpoint — anyone can POST an arbitrary payload to it, and the `{ data }` type on the handler is compile-time fiction with no runtime presence. Without `.validator()`, the handler executes attacker-shaped input as if it matched the type.

**Evidence of violation:** a `.handler(async ({ data }) => ...)` that uses `data`, with no `.validator(` call in the same `createServerFn` chain.

**Incorrect (type annotation only — nothing checks the payload at runtime):**

```ts
export const updateProfile = createServerFn({ method: 'POST' })
  .handler(async ({ data }: { data: { displayName: string } }) => {
    return db.users.update({ displayName: data.displayName })
  })
```

**Correct (schema validates at the wire, and the handler type derives from it):**

```ts
const ProfileSchema = z.object({ displayName: z.string().min(1).max(80) })

export const updateProfile = createServerFn({ method: 'POST' })
  .validator(ProfileSchema)
  .handler(async ({ data }) => {
    return db.users.update({ displayName: data.displayName })
  })
```

Reference: [TanStack Start — Server Functions](https://tanstack.com/start/latest/docs/framework/react/guide/server-functions)
