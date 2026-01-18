---
title: Always Throw Error Instances
impact: MEDIUM
impactDescription: provides stack traces for debugging
tags: error, exceptions, throw, debugging
---

## Always Throw Error Instances

Always throw `Error` or `Error` subclass instances. Never throw strings, objects, or other primitives. Error instances provide stack traces.

**Incorrect (non-Error throws):**

```typescript
// String - no stack trace
throw 'Something went wrong'

// Object - no stack trace
throw { message: 'Failed', code: 500 }

// Number - no context
throw 404
```

**Correct (Error instances):**

```typescript
// Standard Error
throw new Error('Something went wrong')

// Built-in error types
throw new TypeError('Expected string, got number')
throw new RangeError('Index out of bounds')

// Custom error class
class ValidationError extends Error {
  constructor(
    message: string,
    public readonly field: string
  ) {
    super(message)
    this.name = 'ValidationError'
  }
}

throw new ValidationError('Invalid email format', 'email')
```

**Catching unknown errors:**

```typescript
try {
  riskyOperation()
} catch (e: unknown) {
  // Always catch as unknown
  if (e instanceof Error) {
    console.error(e.message, e.stack)
  } else {
    // Handle non-Error throws from third-party code
    throw new Error(`Unexpected error: ${String(e)}`)
  }
}
```

Reference: [Google TypeScript Style Guide - Exceptions](https://google.github.io/styleguide/tsguide.html#exceptions)
