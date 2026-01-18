---
title: Type Catch Clause Variables as Unknown
impact: MEDIUM
impactDescription: enforces safe error handling
tags: error, catch, unknown, type-safety
---

## Type Catch Clause Variables as Unknown

Always type catch clause variables as `unknown` and narrow before use. This prevents accessing properties that may not exist.

**Incorrect (assuming Error type):**

```typescript
try {
  await fetchData()
} catch (e) {
  // e is implicitly 'any' or 'unknown'
  console.log(e.message)  // Might not have message property
  console.log(e.stack)    // Might not have stack property
}
```

**Correct (explicit unknown with narrowing):**

```typescript
try {
  await fetchData()
} catch (e: unknown) {
  // Type guard to safely access Error properties
  if (e instanceof Error) {
    console.error(e.message)
    console.error(e.stack)
  } else {
    // Handle unexpected throw types
    console.error('Unknown error:', String(e))
  }
}
```

**Helper function for error handling:**

```typescript
function getErrorMessage(error: unknown): string {
  if (error instanceof Error) {
    return error.message
  }
  if (typeof error === 'string') {
    return error
  }
  return 'Unknown error occurred'
}

try {
  riskyOperation()
} catch (e: unknown) {
  console.error(getErrorMessage(e))
}
```

Reference: [Google TypeScript Style Guide - Exception handling](https://google.github.io/styleguide/tsguide.html#exceptions)
