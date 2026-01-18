---
title: Avoid Empty Object Type
impact: HIGH
impactDescription: prevents unexpected type widening
tags: types, empty-object, unknown, object
---

## Avoid Empty Object Type

Never use `{}` as a type. It matches almost everything except `null` and `undefined`, which is almost never the intended behavior.

**Incorrect (empty object type):**

```typescript
// Matches strings, numbers, arrays - anything non-nullish
function process(value: {}) {
  // No useful operations available
}

process('string')  // Allowed!
process(123)       // Allowed!
process([1, 2, 3]) // Allowed!
```

**Correct (use appropriate types):**

```typescript
// For any value including null/undefined
function processAnything(value: unknown) {
  // Must narrow type before use
}

// For non-null objects only
function processObject(value: object) {
  // Excludes primitives
}

// For dictionaries with known value type
function processDictionary(value: Record<string, unknown>) {
  // Can iterate over properties
}

// For specific shape
interface Config {
  timeout: number
  retries: number
}
function processConfig(value: Config) {
  // Full type safety
}
```

**Type comparison:**
- `{}` - Everything except `null`/`undefined`
- `object` - Non-primitive values only
- `unknown` - Everything, requires narrowing
- `Record<K, V>` - Dictionary with typed values

Reference: [Google TypeScript Style Guide - {} type](https://google.github.io/styleguide/tsguide.html#the--type)
