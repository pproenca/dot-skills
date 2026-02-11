---
title: Use Base Types Instead of Large Union Types
impact: MEDIUM
impactDescription: avoids O(n²) comparison overhead for large unions
tags: compile, unions, base-types, type-checking-speed
---

## Use Base Types Instead of Large Union Types

When a union type has many members, the compiler must compare each member pairwise to eliminate redundancy -- an O(n²) operation. For unions exceeding ~20 members, use a base type with shared properties instead.

**Incorrect (large union, quadratic comparisons):**

```typescript
type ApiEndpoint =
  | { path: "/users"; method: "GET"; response: User[] }
  | { path: "/users/:id"; method: "GET"; response: User }
  | { path: "/users"; method: "POST"; response: User }
  | { path: "/orders"; method: "GET"; response: Order[] }
  | { path: "/orders/:id"; method: "GET"; response: Order }
  // ... 50 more endpoints
  // Compiler does n² comparisons on every type check
```

**Correct (base interface with generic parameter):**

```typescript
interface ApiEndpoint<TPath extends string, TMethod extends string, TResponse> {
  path: TPath
  method: TMethod
  response: TResponse
}

interface EndpointMap {
  "GET /users": ApiEndpoint<"/users", "GET", User[]>
  "GET /users/:id": ApiEndpoint<"/users/:id", "GET", User>
  "POST /users": ApiEndpoint<"/users", "POST", User>
  "GET /orders": ApiEndpoint<"/orders", "GET", Order[]>
}

type Endpoint = EndpointMap[keyof EndpointMap]
```

Reference: [TypeScript Performance Wiki - Preferring Base Types Over Unions](https://github.com/microsoft/TypeScript/wiki/Performance#preferring-base-types-over-unions)
