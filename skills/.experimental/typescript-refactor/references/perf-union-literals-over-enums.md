---
title: Use Union Literals Instead of Enums
impact: MEDIUM
impactDescription: saves 100-500 bytes per enum, enables tree-shaking
tags: perf, unions, enums, bundle-size
---

## Use Union Literals Instead of Enums

Regular enums emit a runtime lookup object with forward and reverse mappings, adding bundle size. Union literal types exist only at compile time — zero runtime cost, full tree-shaking, and simpler debugging output.

**Incorrect (enum emits runtime object):**

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
// Emits: var OrderStatus; (function(OrderStatus) { ... })(OrderStatus || ...)
```

**Correct (union literal, zero runtime cost):**

```typescript
type OrderStatus = "pending" | "processing" | "shipped" | "delivered"

function isComplete(status: OrderStatus): boolean {
  return status === "delivered"
}
// Emits: function isComplete(status) { return status === "delivered" }
```

**When NOT to use this pattern:**
- When you need runtime iteration over all values (use `as const` array instead)
- When reverse mapping (value → key) is required

Reference: [Google TypeScript Style Guide](https://google.github.io/styleguide/tsguide.html)
