---
title: Parse external data with a schema instead of as-casting it
tags: types, validation, zod, boundaries
---

## Parse external data with a schema instead of as-casting it

The wrong default is `(await res.json()) as User`. Type assertions are erased at compile time — the handbook is explicit that no exception or null is produced when the assertion is wrong — so the cast mislabels whatever actually arrived and the type error surfaces later as a property crash far from the fetch. External data (network responses, `JSON.parse`, `localStorage`, route params, form data) gets typed `unknown` and schema-parsed once at the boundary; validated domain types flow inward from there.

**Evidence of violation:** an `as SomeType` assertion applied to the result of `res.json()`, `JSON.parse(`, `localStorage.getItem(`, or a route/search param accessor, with no `.parse(`/`.safeParse(` applied to that value.

**Incorrect (the network is not statically typed):**

```ts
const res = await fetch(`/api/users/${userId}`)
const user = (await res.json()) as User
```

**Correct (schema is the single source of truth; type derives from it):**

```ts
const UserSchema = z.object({ id: z.string(), email: z.string().email() })
type User = z.infer<typeof UserSchema>

const res = await fetch(`/api/users/${userId}`)
const user = UserSchema.parse(await res.json())
```

Reference: [TypeScript Handbook — Type Assertions](https://www.typescriptlang.org/docs/handbook/2/everyday-types.html#type-assertions), [Effective TypeScript — Runtime Types](https://effectivetypescript.com/2024/10/31/runtime-types/), [Zod](https://zod.dev/)
