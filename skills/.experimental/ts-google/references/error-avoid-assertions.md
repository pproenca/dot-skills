---
title: Avoid Type and Non-Null Assertions
impact: MEDIUM
impactDescription: prevents hiding type errors
tags: error, assertions, type-safety, non-null
---

## Avoid Type and Non-Null Assertions

Minimize use of type assertions (`as`) and non-null assertions (`!`). They suppress compiler checks and can hide real bugs.

**Incorrect (unnecessary assertions):**

```typescript
// Non-null assertion hiding potential bug
const name = user!.name  // What if user is null?

// Type assertion without validation
const data = response as UserData  // What if response shape is wrong?

// Double assertion (especially dangerous)
const element = unknownValue as unknown as HTMLElement
```

**Correct (runtime checks or proper typing):**

```typescript
// Runtime check instead of assertion
if (!user) {
  throw new Error('User is required')
}
const name = user.name  // TypeScript knows user is not null

// Type guard for validation
function isUserData(value: unknown): value is UserData {
  return (
    typeof value === 'object' &&
    value !== null &&
    'name' in value &&
    'email' in value
  )
}

if (!isUserData(response)) {
  throw new Error('Invalid user data')
}
const data = response  // Properly typed

// Explicit annotation instead of assertion
const config: Config = { timeout: 5000, retries: 3 }
```

**When assertions are acceptable:**

```typescript
// With explanatory comment
const element = document.getElementById('app')
// Element exists because we control the HTML
const root = element as HTMLElement
```

Reference: [Google TypeScript Style Guide - Type assertions](https://google.github.io/styleguide/tsguide.html#type-assertions)
