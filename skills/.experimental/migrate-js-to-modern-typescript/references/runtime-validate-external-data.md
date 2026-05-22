---
title: Validate External Data at the Boundary
impact: MEDIUM-HIGH
impactDescription: prevents malformed-data crashes
tags: runtime, validation, boundaries, zod
---

## Validate External Data at the Boundary

API responses, JSON files, and message payloads are `any` or `unknown` at runtime regardless of the annotation you write — casting them to a type is a claim the compiler cannot verify and the network does not honor. A schema validator (Zod, valibot) checks the shape once at the boundary and returns a value whose static type is guaranteed to match what actually arrived.

**Incorrect (cast trusts the network blindly):**

```typescript
async function fetchUser(id: string): Promise<User> {
  const res = await fetch(`/api/users/${id}`)
  return (await res.json()) as User // any malformed response crashes downstream
}
```

**Correct (validate, then the type is guaranteed):**

```typescript
import { z } from "zod"

const UserSchema = z.object({
  id: z.string(),
  email: z.email(), // Zod v4 top-level format helper
  createdAt: z.coerce.date(),
})

async function fetchUser(id: string): Promise<User> {
  const res = await fetch(`/api/users/${id}`)
  return UserSchema.parse(await res.json()) // throws with a precise path on mismatch
}
```

Reference: [Zod: Basics](https://zod.dev/basics)
