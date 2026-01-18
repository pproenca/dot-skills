---
title: Always Use Triple Equals
impact: MEDIUM-HIGH
impactDescription: prevents type coercion bugs
tags: control, equality, strict-equality, comparison
---

## Always Use Triple Equals

Always use `===` and `!==` instead of `==` and `!=`. The loose equality operators perform type coercion, leading to unexpected results.

**Incorrect (loose equality):**

```typescript
if (value == null) {
  // Matches both null and undefined - sometimes intentional
}

if (count == '0') {
  // true! Number coerced to string
}

if (arr == false) {
  // Empty array is truthy, but this can be true in edge cases
}
```

**Correct (strict equality):**

```typescript
if (value === null || value === undefined) {
  // Explicit null/undefined check
}

// Or use nullish check when intentional
if (value == null) {  // ONLY exception - checking null OR undefined
  // Clearly checking for both null and undefined
}

if (count === 0) {
  // Type-safe comparison
}

if (arr.length === 0) {
  // Explicit empty array check
}
```

**The only acceptable use of ==:**

```typescript
// Checking for both null and undefined simultaneously
if (value == null) {
  // Equivalent to: value === null || value === undefined
}
```

Reference: [Google TypeScript Style Guide - Equality checks](https://google.github.io/styleguide/tsguide.html#equality-checks)
