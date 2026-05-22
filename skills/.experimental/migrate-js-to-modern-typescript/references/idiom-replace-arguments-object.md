---
title: Replace the arguments Object with Rest Parameters
impact: MEDIUM
impactDescription: enables typed variadic arguments
tags: idiom, rest-parameters, arguments, variadic
---

## Replace the arguments Object with Rest Parameters

The `arguments` object is untyped, only array-like (so it lacks `map`, `reduce`, and friends), and unavailable inside arrow functions. A typed rest parameter (`...values: number[]`) gives each argument a checked type and a real array, so variadic functions are both safe and ergonomic after migration.

**Incorrect (arguments object — untyped and not a real array):**

```typescript
function sum() {
  // arguments is array-like and untyped; .reduce is not available on it.
  let total = 0
  for (let i = 0; i < arguments.length; i++) {
    total += arguments[i]
  }
  return total
}
```

**Correct (typed rest parameter):**

```typescript
function sum(...values: number[]): number {
  return values.reduce((total, value) => total + value, 0)
}
```

Reference: [TypeScript Handbook: Rest Parameters](https://www.typescriptlang.org/docs/handbook/2/functions.html#rest-parameters-and-arguments)
