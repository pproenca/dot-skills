---
title: Never Use Wrapper Object Types
impact: CRITICAL
impactDescription: prevents type confusion and boxing overhead
tags: types, primitives, wrappers, string, number, boolean
---

## Never Use Wrapper Object Types

Never use wrapper types (`String`, `Boolean`, `Number`, `Symbol`, `BigInt`). Use lowercase primitive types. Never instantiate wrappers with `new`.

**Incorrect (wrapper types):**

```typescript
// Wrapper types as annotations
function greet(name: String): Boolean {
  return name.length > 0
}

// Instantiating wrapper objects
const message = new String('hello')
const count = new Number(42)
const flag = new Boolean(true)

// These create objects, not primitives!
typeof message  // 'object', not 'string'
```

**Correct (primitive types):**

```typescript
// Primitive type annotations
function greet(name: string): boolean {
  return name.length > 0
}

// Literal values
const message = 'hello'
const count = 42
const flag = true

// Coercion without new
const str = String(someValue)
const num = Number(someValue)
const bool = Boolean(someValue)
```

**Why this matters:**
- `String !== string` in TypeScript
- Wrapper objects have different identity semantics
- Unnecessary memory allocation
- Confusing behavior in comparisons

Reference: [Google TypeScript Style Guide - Wrapper types](https://google.github.io/styleguide/tsguide.html#wrapper-types)
