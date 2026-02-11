---
title: Use typeof Narrowing Before Property Access
impact: HIGH
impactDescription: prevents runtime TypeError on unexpected types
tags: narrow, typeof, narrowing, defensive-coding
---

## Use typeof Narrowing Before Property Access

Accessing properties on `unknown`, union types, or external input without narrowing causes runtime errors. Chain `typeof` checks to narrow progressively — TypeScript tracks each check and narrows the type within each branch.

**Incorrect (no narrowing, runtime crash on wrong type):**

```typescript
function formatValue(value: string | number | boolean): string {
  return value.toFixed(2) // Runtime error if string or boolean
}
```

**Correct (typeof narrows each branch):**

```typescript
function formatValue(value: string | number | boolean): string {
  if (typeof value === "number") {
    return value.toFixed(2)
  }
  if (typeof value === "boolean") {
    return value ? "yes" : "no"
  }
  return value // Already narrowed to string
}
```
