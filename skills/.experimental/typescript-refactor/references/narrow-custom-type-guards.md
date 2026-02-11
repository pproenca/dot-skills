---
title: Write Custom Type Guards Instead of Type Assertions
impact: CRITICAL
impactDescription: eliminates unsafe as casts with runtime-verified narrowing
tags: narrow, type-guards, type-predicates, narrowing
---

## Write Custom Type Guards Instead of Type Assertions

Type assertions (`as`) silence the compiler without runtime verification. Custom type guards with `is` predicates combine runtime checks with type narrowing, making the code both safe and ergonomic.

**Incorrect (assertion trusts the developer, not the runtime):**

```typescript
interface ApiResponse {
  status: number
  payload: unknown
}

function handleSuccess(response: ApiResponse) {
  const users = response.payload as User[] // Unsafe — no runtime check
  users.forEach(user => console.log(user.email))
}
```

**Correct (type guard verifies at runtime):**

```typescript
interface ApiResponse {
  status: number
  payload: unknown
}

function isUserArray(value: unknown): value is User[] {
  return Array.isArray(value) && value.every(
    item => typeof item === "object" && item !== null && "email" in item
  )
}

function handleSuccess(response: ApiResponse) {
  if (!isUserArray(response.payload)) throw new Error("Invalid payload")
  response.payload.forEach(user => console.log(user.email)) // Narrowed to User[]
}
```

Reference: [TypeScript Handbook - Type Predicates](https://www.typescriptlang.org/docs/handbook/2/narrowing.html#using-type-predicates)
