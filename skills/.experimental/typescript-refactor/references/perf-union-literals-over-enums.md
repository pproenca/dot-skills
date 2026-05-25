---
title: Use Union Literals Instead of Enums
impact: MEDIUM
impactDescription: removes non-erasable runtime emit; enables type-stripping
tags: perf, unions, enums, erasable-syntax
---

## Use Union Literals Instead of Enums

The decisive problem with `enum` is no longer bundle size — it is that enums emit a runtime lookup object, so they are **non-erasable**. They error under `erasableSyntaxOnly` (TS 5.8) and will not run under Node.js native type-stripping. Union literal types exist only at compile time: nothing to emit, nothing to strip, and simpler debugging output.

**Incorrect (enum emits a runtime object; fails type-stripping):**

```typescript
enum OrderStatus {
  Pending = "pending",
  Processing = "processing",
  Shipped = "shipped",
  Delivered = "delivered",
}

function isComplete(status: OrderStatus): boolean {
  return status === OrderStatus.Delivered
}
// Emits a runtime IIFE — rejected when types are stripped, not compiled
```

**Correct (union literal, fully erasable):**

```typescript
type OrderStatus = "pending" | "processing" | "shipped" | "delivered"

function isComplete(status: OrderStatus): boolean {
  return status === "delivered"
}
// Erases to: function isComplete(status) { return status === "delivered" }
```

**When you need the runtime values** (iteration, reverse lookup), use an erasable `as const` object instead of an enum:

```typescript
const OrderStatus = {
  Pending: "pending", Processing: "processing",
  Shipped: "shipped", Delivered: "delivered",
} as const
type OrderStatus = (typeof OrderStatus)[keyof typeof OrderStatus]
```

See [`modern-erasable-syntax`](modern-erasable-syntax.md) for the broader erasability rule.

Reference: [TypeScript 5.8 — erasableSyntaxOnly](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-5-8.html)
