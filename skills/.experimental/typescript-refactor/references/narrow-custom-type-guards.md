---
title: Write Custom Type Guards Instead of Type Assertions
impact: CRITICAL
impactDescription: eliminates unsafe as casts with runtime-verified narrowing
tags: narrow, type-guards, type-predicates, narrowing
---

## Write Custom Type Guards Instead of Type Assertions

Type assertions (`as`) silence the compiler without runtime verification. Replace them with a function that actually checks the value: TypeScript 5.5+ **infers the type predicate** from a guard whose body is a single boolean `return`, so a plain `boolean` return narrows callers without writing `is` at all. Reserve an explicit `is` annotation for guards with multiple returns or those you want to document as a contract — for example exported guards.

**Incorrect (assertion trusts the developer, not the runtime):**

```typescript
interface ApiResponse {
  status: number
  payload: unknown
}

function handleSuccess(response: ApiResponse) {
  const order = response.payload as Order // Unsafe — no runtime check
  console.log(order.total)
}
```

**Correct (TS 5.5+ infers the predicate from a single-return body):**

```typescript
function isOrder(value: unknown) {
  return (
    typeof value === "object" && value !== null &&
    "total" in value && typeof value.total === "number"
  )
}
// Inferred signature: (value: unknown) => value is { total: number }

function handleSuccess(response: ApiResponse) {
  if (!isOrder(response.payload)) throw new Error("Invalid payload")
  console.log(response.payload.total) // Narrowed — no `as`
}
```

Annotate `value is Order` explicitly when the body branches across several returns (inference only fires on a single return) or to lock the public contract of an exported guard.

Reference: [TypeScript 5.5 — Inferred Type Predicates](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-5-5.html#inferred-type-predicates)
