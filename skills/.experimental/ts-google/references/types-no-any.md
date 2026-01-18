---
title: Never Use the any Type
impact: CRITICAL
impactDescription: prevents undetected type errors throughout codebase
tags: types, any, type-safety, unknown
---

## Never Use the any Type

The `any` type allows assignment into any other type and dereferencing any property, completely disabling type checking and enabling undetected errors.

**Incorrect (using any):**

```typescript
function processData(data: any) {
  return data.items.map((item: any) => item.value)
  // No type checking - typos, wrong properties, all pass silently
}

const result = processData({ itms: [] })  // Typo not caught
```

**Correct (use specific types or unknown):**

```typescript
interface DataPayload {
  items: Array<{ value: number }>
}

function processData(data: DataPayload) {
  return data.items.map((item) => item.value)
  // Full type checking
}

const result = processData({ itms: [] })  // Error: 'itms' not in DataPayload
```

**Alternative (use unknown for truly unknown values):**

```typescript
function processUnknown(data: unknown) {
  // Must narrow type before use
  if (typeof data === 'object' && data !== null && 'items' in data) {
    // Safe to access data.items
  }
}
```

**When you think you need any:**
1. Define an interface for the expected shape
2. Use `unknown` with type narrowing
3. Use generics for flexible typing

Reference: [Google TypeScript Style Guide - Any type](https://google.github.io/styleguide/tsguide.html#any)
