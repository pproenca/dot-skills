---
title: Mark Properties Readonly When Never Reassigned
impact: HIGH
impactDescription: prevents accidental mutations and enables optimizations
tags: class, readonly, immutability, type-safety
---

## Mark Properties Readonly When Never Reassigned

Properties that are never reassigned outside of the constructor should be marked `readonly` to prevent accidental mutations and communicate intent.

**Incorrect (mutable when not needed):**

```typescript
class User {
  id: string
  name: string
  createdAt: Date

  constructor(id: string, name: string) {
    this.id = id
    this.name = name
    this.createdAt = new Date()
  }

  updateName(name: string) {
    this.name = name
    this.id = 'new-id'  // Bug: accidentally mutated id
  }
}
```

**Correct (readonly for immutable properties):**

```typescript
class User {
  readonly id: string
  name: string  // Only name is mutable
  readonly createdAt: Date

  constructor(id: string, name: string) {
    this.id = id
    this.name = name
    this.createdAt = new Date()
  }

  updateName(name: string) {
    this.name = name
    this.id = 'new-id'  // Error: Cannot assign to 'id' because it is read-only
  }
}
```

**Benefits:**
- Compile-time protection against accidental mutation
- Documents immutability intent
- Enables compiler optimizations
- Safer refactoring

Reference: [Google TypeScript Style Guide - Field initialization](https://google.github.io/styleguide/tsguide.html#field-initialization)
