---
title: Default to Readonly Types
impact: HIGH
impactDescription: prevents accidental mutation, catches side-effect bugs at compile time
tags: arch, readonly, immutability, defensive-typing
---

## Default to Readonly Types

Mutable types permit accidental mutation that causes subtle bugs — especially when objects are shared across functions. Default to `Readonly<T>`, `readonly` properties, and `ReadonlyArray<T>`, then selectively opt into mutation only where needed.

**Incorrect (mutable by default, mutation leaks):**

```typescript
function sortUsersByAge(users: User[]) {
  return users.sort((a, b) => a.age - b.age) // Mutates the original array
}

const activeUsers = getActiveUsers()
const sorted = sortUsersByAge(activeUsers) // activeUsers is now also sorted
```

**Correct (readonly prevents accidental mutation):**

```typescript
function sortUsersByAge(users: readonly User[]) {
  return [...users].sort((a, b) => a.age - b.age) // Copy first
}

const activeUsers = getActiveUsers()
const sorted = sortUsersByAge(activeUsers) // activeUsers unchanged
```

**Note:** Use `Readonly<T>` for objects and `readonly T[]` or `ReadonlyArray<T>` for arrays. Prefer `ReadonlyMap` and `ReadonlySet` for collections.
