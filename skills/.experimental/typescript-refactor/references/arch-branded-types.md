---
title: Use Branded Types for Domain Identifiers
impact: CRITICAL
impactDescription: prevents cross-domain ID mix-ups at compile time
tags: arch, branded-types, type-safety, domain-modeling
---

## Use Branded Types for Domain Identifiers

Plain `string` or `number` types allow accidental swaps between semantically different identifiers. Branded types add a phantom tag that makes each ID type unique without runtime overhead.

**Incorrect (all IDs are plain strings):**

```typescript
function assignOrder(userId: string, orderId: string) {
  // ...
}

const userId = "usr_abc123"
const orderId = "ord_xyz789"

assignOrder(orderId, userId) // Swapped — compiles fine, fails silently
```

**Correct (branded types catch swaps):**

```typescript
type UserId = string & { readonly __brand: "UserId" }
type OrderId = string & { readonly __brand: "OrderId" }

function assignOrder(userId: UserId, orderId: OrderId) {
  // ...
}

const userId = "usr_abc123" as UserId
const orderId = "ord_xyz789" as OrderId

assignOrder(orderId, userId) // Compile error: OrderId not assignable to UserId
```

**Alternative (factory function avoids `as` casts):**

```typescript
function createUserId(raw: string): UserId {
  if (!raw.startsWith("usr_")) throw new Error("Invalid user ID")
  return raw as UserId
}
```

Reference: [TypeScript Handbook - Type Branding](https://www.typescriptlang.org/docs/handbook/2/types-from-types.html)
