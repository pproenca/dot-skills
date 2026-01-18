---
title: Prefer for-of Over for-in for Arrays
impact: MEDIUM-HIGH
impactDescription: prevents prototype property enumeration bugs
tags: control, loops, for-of, for-in, iteration
---

## Prefer for-of Over for-in for Arrays

Use `for-of` loops for arrays and iterables. Use `Object.keys()`, `Object.values()`, or `Object.entries()` for objects. Never use unfiltered `for-in`.

**Incorrect (for-in on array):**

```typescript
const items = ['a', 'b', 'c']

for (const i in items) {
  console.log(items[i])  // i is string, enumerates inherited properties
}

// If Array.prototype is extended, this iterates those too
```

**Correct (for-of for arrays):**

```typescript
const items = ['a', 'b', 'c']

// Direct value access
for (const item of items) {
  console.log(item)
}

// When index is needed
for (const [index, item] of items.entries()) {
  console.log(index, item)
}
```

**Correct (Object methods for objects):**

```typescript
const config = { timeout: 5000, retries: 3 }

// Keys only
for (const key of Object.keys(config)) {
  console.log(key)
}

// Values only
for (const value of Object.values(config)) {
  console.log(value)
}

// Key-value pairs
for (const [key, value] of Object.entries(config)) {
  console.log(key, value)
}
```

**If for-in is required, always filter:**

```typescript
for (const key in obj) {
  if (Object.prototype.hasOwnProperty.call(obj, key)) {
    // Safe to use obj[key]
  }
}
```

Reference: [Google TypeScript Style Guide - Iterating objects](https://google.github.io/styleguide/tsguide.html#iterating-objects)
