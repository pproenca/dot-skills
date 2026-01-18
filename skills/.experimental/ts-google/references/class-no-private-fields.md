---
title: Use TypeScript Private Over Private Fields
impact: HIGH
impactDescription: consistent access control without runtime overhead
tags: class, private, visibility, encapsulation
---

## Use TypeScript Private Over Private Fields

Use TypeScript's `private` modifier instead of JavaScript private fields (`#field`). Private fields have runtime costs and interact poorly with TypeScript features.

**Incorrect (JavaScript private fields):**

```typescript
class Counter {
  #count = 0  // JavaScript private field

  increment() {
    this.#count++
  }

  getCount() {
    return this.#count
  }
}
// Compiles to WeakMap usage, adds runtime overhead
// Cannot be accessed in tests, even with type assertions
```

**Correct (TypeScript private modifier):**

```typescript
class Counter {
  private count = 0  // TypeScript private

  increment() {
    this.count++
  }

  getCount() {
    return this.count
  }
}
// No runtime overhead, compile-time enforcement
// Can be accessed in tests via type assertions if needed
```

**Visibility guidelines:**
- Use `private` for internal implementation details
- Use `protected` for subclass-accessible members
- Omit `public` modifier (it's the default)
- Exception: `public readonly` for parameter properties

Reference: [Google TypeScript Style Guide - Private fields](https://google.github.io/styleguide/tsguide.html#private-fields)
