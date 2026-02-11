---
title: Use Discriminated Unions Over String Enums
impact: CRITICAL
impactDescription: eliminates entire classes of invalid state bugs
tags: arch, discriminated-unions, enums, pattern-matching
---

## Use Discriminated Unions Over String Enums

String enums provide no structural guarantee about which properties exist for a given variant. Discriminated unions tie shape to kind, making invalid states unrepresentable and enabling exhaustive pattern matching.

**Incorrect (string enum with loose object):**

```typescript
enum OrderStatus {
  Pending = "pending",
  Shipped = "shipped",
  Delivered = "delivered",
}

interface Order {
  id: string
  status: OrderStatus
  trackingNumber?: string  // Optional for all statuses — easy to forget
  deliveredAt?: Date
}

function processOrder(order: Order) {
  if (order.status === OrderStatus.Shipped) {
    console.log(order.trackingNumber) // Could be undefined
  }
}
```

**Correct (discriminated union, shape tied to status):**

```typescript
interface PendingOrder {
  id: string
  status: "pending"
}

interface ShippedOrder {
  id: string
  status: "shipped"
  trackingNumber: string  // Required — compiler enforces it
}

interface DeliveredOrder {
  id: string
  status: "delivered"
  trackingNumber: string
  deliveredAt: Date
}

type Order = PendingOrder | ShippedOrder | DeliveredOrder

function processOrder(order: Order) {
  if (order.status === "shipped") {
    console.log(order.trackingNumber) // Guaranteed to exist
  }
}
```

**When NOT to use this pattern:**
- Simple enumerations with no variant-specific data (e.g., log levels)
- When you need runtime iteration over all values

Reference: [TypeScript Handbook - Narrowing](https://www.typescriptlang.org/docs/handbook/2/narrowing.html)
