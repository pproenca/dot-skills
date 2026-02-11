---
title: Break Circular Dependencies with Intermediate Modules
impact: MEDIUM
impactDescription: eliminates undefined-at-import-time bugs, enables proper tree shaking
tags: couple, circular-dependencies, module-graph, refactoring
---

## Break Circular Dependencies with Intermediate Modules

When module A imports from B and B imports from A, one of them receives `undefined` at load time because the other has not finished executing. This causes silent runtime crashes that only surface in production. Extracting the shared dependency into a third module breaks the cycle and makes the dependency graph acyclic.

**Incorrect (circular import — OrderItem is undefined at runtime):**

```tsx
// order.ts
import { OrderItem } from "./orderItem"; // orderItem.ts hasn't finished loading

export interface Order {
  id: string;
  customer: string;
  items: OrderItem[];
}

export function calculateOrderTotal(order: Order): number {
  return order.items.reduce((sum, item) => sum + item.price * item.quantity, 0);
}

// orderItem.ts
import { calculateOrderTotal } from "./order"; // circular: order -> orderItem -> order

export interface OrderItem {
  id: string;
  productName: string;
  price: number;
  quantity: number;
}

export function formatItemWithOrderTotal(item: OrderItem, order: Order): string {
  const total = calculateOrderTotal(order);
  return `${item.productName} (${((item.price * item.quantity) / total * 100).toFixed(1)}% of order)`;
}
```

**Correct (shared types extracted — acyclic dependency graph):**

```tsx
// order.types.ts — shared types, no logic, no imports from siblings
export interface Order {
  id: string;
  customer: string;
  items: OrderItem[];
}

export interface OrderItem {
  id: string;
  productName: string;
  price: number;
  quantity: number;
}

// order.ts — depends on types only
import type { Order } from "./order.types";

export function calculateOrderTotal(order: Order): number {
  return order.items.reduce((sum, item) => sum + item.price * item.quantity, 0);
}

// orderItem.ts — depends on types and order, no cycle
import type { Order, OrderItem } from "./order.types";
import { calculateOrderTotal } from "./order";

export function formatItemWithOrderTotal(item: OrderItem, order: Order): string {
  const total = calculateOrderTotal(order);
  return `${item.productName} (${((item.price * item.quantity) / total * 100).toFixed(1)}% of order)`;
}
```

Reference: [Node.js Docs - Cycles](https://nodejs.org/api/modules.html#cycles)
