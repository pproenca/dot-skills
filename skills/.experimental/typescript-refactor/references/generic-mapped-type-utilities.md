---
title: Build Custom Mapped Types for Repeated Transformations
impact: MEDIUM
impactDescription: eliminates manual type duplication across related interfaces
tags: generic, mapped-types, utility-types, type-transformations
---

## Build Custom Mapped Types for Repeated Transformations

When you find yourself writing multiple interfaces that are variations of the same shape (nullable version, event version, partial version), extract a mapped type utility. This keeps types in sync as the base type evolves.

**Incorrect (manual duplication drifts over time):**

```typescript
interface User {
  id: string
  name: string
  email: string
}

interface UserUpdate {
  id?: string
  name?: string
  email?: string
}

interface UserEvents {
  onIdChange: (value: string) => void
  onNameChange: (value: string) => void
  onEmailChange: (value: string) => void
  // Adding a field to User? Must update here too
}
```

**Correct (mapped types derive from source):**

```typescript
interface User {
  id: string
  name: string
  email: string
}

type UserUpdate = Partial<User>

type EventHandlers<T> = {
  [K in keyof T as `on${Capitalize<string & K>}Change`]: (value: T[K]) => void
}

type UserEvents = EventHandlers<User>
// Automatically includes onIdChange, onNameChange, onEmailChange
// Adding a field to User? UserEvents updates automatically
```

Reference: [TypeScript Handbook - Mapped Types](https://www.typescriptlang.org/docs/handbook/2/mapped-types.html)
