---
title: Annotate Exported Function Signatures Explicitly
impact: HIGH
impactDescription: prevents silent contract drift
tags: surface, exports, return-types, contracts
---

## Annotate Exported Function Signatures Explicitly

An exported function's signature is the contract every importer depends on. When the return type is inferred, a change to the body can silently widen that contract and leak an internal type to all callers with no local error. An explicit return type locks the contract, makes the compiler check the body against it, and removes inference work that slows large-project type-checking.

**Incorrect (inferred export — return type drifts with the body):**

```typescript
// The return type is inferred. Adding a cache field later silently widens
// the public shape and leaks an internal detail to every caller.
export function loadOrder(id: string) {
  const order = db.orders.find(id)
  return { ...order, _cacheKey: `order:${id}` }
}
```

**Correct (explicit signature — body checked against the contract):**

```typescript
export function loadOrder(id: string): Order {
  const order = db.orders.find(id)
  return order // the compiler now rejects an accidental extra public field
}
```

Reference: [TypeScript Performance: Using Type Annotations](https://github.com/microsoft/TypeScript/wiki/Performance#using-type-annotations)
