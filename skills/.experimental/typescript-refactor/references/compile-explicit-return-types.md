---
title: Add Explicit Return Types to Exported Functions
impact: MEDIUM-HIGH
impactDescription: measurably faster incremental builds in large codebases
tags: compile, return-types, incremental-builds, declaration-files
---

## Add Explicit Return Types to Exported Functions

Without explicit return types, the compiler must re-infer return types from function bodies on every compilation and when generating declaration files. Explicit return types on public API boundaries enable faster incremental builds and make `.d.ts` output predictable.

**Incorrect (compiler re-infers on every build):**

```typescript
export function createOrderSummary(order: Order) {
  const subtotal = order.items.reduce((sum, item) => sum + item.price, 0)
  const tax = subtotal * order.taxRate
  return {
    orderId: order.id,
    subtotal,
    tax,
    total: subtotal + tax,
    itemCount: order.items.length,
  }
  // Compiler must analyze body to determine return type
}
```

**Correct (return type explicit, faster builds):**

```typescript
interface OrderSummary {
  orderId: string
  subtotal: number
  tax: number
  total: number
  itemCount: number
}

export function createOrderSummary(order: Order): OrderSummary {
  const subtotal = order.items.reduce((sum, item) => sum + item.price, 0)
  const tax = subtotal * order.taxRate
  return {
    orderId: order.id,
    subtotal,
    tax,
    total: subtotal + tax,
    itemCount: order.items.length,
  }
}
```

**Note:** Internal/private functions benefit less — focus on exported APIs and module boundaries. Exception: generic functions where inference carries type parameters through (see `generic-return-type-inference`).

Reference: [TypeScript Performance Wiki - Using Type Annotations](https://github.com/microsoft/TypeScript/wiki/Performance#using-type-annotations)
