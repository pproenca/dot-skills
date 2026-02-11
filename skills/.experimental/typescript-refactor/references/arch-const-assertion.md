---
title: Use as const for Immutable Literal Inference
impact: HIGH
impactDescription: prevents type widening, enables literal-based narrowing
tags: arch, const-assertion, literals, immutability
---

## Use as const for Immutable Literal Inference

Without `as const`, TypeScript widens object and array literals to mutable base types. `as const` preserves exact literal types and marks everything readonly, enabling discriminated unions, tuple inference, and compile-time validation.

**Incorrect (literals widened to base types):**

```typescript
const httpMethods = ["GET", "POST", "PUT", "DELETE"]
// Type: string[] — literals lost

const endpoint = { path: "/users", method: "GET" }
// Type: { path: string; method: string } — not assignable to literal unions
```

**Correct (literals preserved with as const):**

```typescript
const httpMethods = ["GET", "POST", "PUT", "DELETE"] as const
// Type: readonly ["GET", "POST", "PUT", "DELETE"]

const endpoint = { path: "/users", method: "GET" } as const
// Type: { readonly path: "/users"; readonly method: "GET" }

type HttpMethod = (typeof httpMethods)[number] // "GET" | "POST" | "PUT" | "DELETE"
```

Reference: [TypeScript Handbook - const assertions](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-3-4.html)
