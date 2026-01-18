---
title: Explicitly Annotate Structural Types
impact: CRITICAL
impactDescription: catches type mismatches at declaration site
tags: types, structural-typing, annotations, type-safety
---

## Explicitly Annotate Structural Types

Always explicitly declare structural types for objects. This catches field mismatches at the declaration site rather than at usage.

**Incorrect (inferred type):**

```typescript
interface User {
  name: string
  email: string
}

// Type is inferred, typo not caught here
const user = {
  name: 'Alice',
  emial: 'alice@example.com',  // Typo!
}

function sendEmail(user: User) {
  console.log(user.email)
}

sendEmail(user)  // Error here, far from source
```

**Correct (explicit annotation):**

```typescript
interface User {
  name: string
  email: string
}

// Error caught immediately at declaration
const user: User = {
  name: 'Alice',
  emial: 'alice@example.com',  // Error: 'emial' does not exist in type 'User'
}
```

**Alternative (satisfies for inference with checking):**

```typescript
const user = {
  name: 'Alice',
  email: 'alice@example.com',
} satisfies User
// Type is inferred but validated against User
```

**Benefits:**
- Errors appear at the source, not at usage
- Self-documenting code
- Better refactoring support

Reference: [Google TypeScript Style Guide - Structural types](https://google.github.io/styleguide/tsguide.html#structural-types-vs-nominal-types)
