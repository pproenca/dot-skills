---
title: Prioritize strictNullChecks for the Highest Bug Yield
impact: CRITICAL
impactDescription: prevents the most common JS runtime crash
tags: strict, strictnullchecks, null-safety
---

## Prioritize strictNullChecks for the Highest Bug Yield

Without `strictNullChecks`, `null` and `undefined` are assignable to every type, so TypeScript cannot catch the single most common JavaScript crash — reading a property of `undefined`. It is the highest-value flag in any migration; sequence it immediately after `noImplicitAny`, since enabling it later means re-auditing code you already touched.

**Incorrect (strictNullChecks off — undefined access compiles):**

```typescript
function getEmail(users: Map<string, User>, id: string): string {
  const user = users.get(id) // typed `User`, but actually `User | undefined`
  return user.email // compiles, throws at runtime when id is absent
}
```

**Correct (strictNullChecks on — the gap is a compile error):**

```typescript
function getEmail(users: Map<string, User>, id: string): string {
  const user = users.get(id) // now typed `User | undefined`
  if (!user) throw new Error(`No user for id ${id}`)
  return user.email // narrowed to `User`, safe to access
}
```

Reference: [tsconfig: strictNullChecks](https://www.typescriptlang.org/tsconfig/#strictNullChecks)
