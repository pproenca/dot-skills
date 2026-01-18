---
title: Prefer Interfaces Over Type Aliases for Objects
impact: CRITICAL
impactDescription: better error messages and IDE performance
tags: types, interfaces, type-aliases, objects
---

## Prefer Interfaces Over Type Aliases for Objects

Interfaces provide better error messages (at declaration vs usage), better IDE support, and clearer semantics for object shapes.

**Incorrect (type alias for object):**

```typescript
type User = {
  firstName: string
  lastName: string
  email: string
}

type UserWithId = User & {
  id: string
}
```

**Correct (interface):**

```typescript
interface User {
  firstName: string
  lastName: string
  email: string
}

interface UserWithId extends User {
  id: string
}
```

**When to use type aliases:**
- Union types: `type Status = 'pending' | 'active' | 'inactive'`
- Mapped types: `type Readonly<T> = { readonly [K in keyof T]: T[K] }`
- Tuple types: `type Point = [number, number]`
- Function types: `type Handler = (event: Event) => void`

**Benefits of interfaces:**
- Declaration merging for extending third-party types
- Better error locality (errors at interface, not usage)
- More intuitive `extends` vs `&` for inheritance
- Better TypeScript compiler performance

Reference: [Google TypeScript Style Guide - Interfaces vs Type Aliases](https://google.github.io/styleguide/tsguide.html#interfaces-vs-type-aliases)
