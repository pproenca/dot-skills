---
title: Write Compiler-Friendly Component Patterns
impact: CRITICAL
impactDescription: 2-10× automatic render optimization
tags: compiler, memoization, purity, idiomatic
---

## Write Compiler-Friendly Component Patterns

React Compiler auto-memoizes components and hooks, but bails out when it encounters mutation, non-idiomatic control flow, or impure render logic. Writing idiomatic React unlocks automatic optimization that replaces all manual useMemo/useCallback/memo calls.

**Incorrect (mutations and impurity cause compiler bailout):**

```tsx
function OrderSummary({ orders }: { orders: Order[] }) {
  const sorted = orders.sort((a, b) => b.total - a.total) // mutates input array
  const totals: Record<string, number> = {}

  for (const order of sorted) {
    totals[order.status] = (totals[order.status] ?? 0) + order.total // builds object via mutation
  }

  let discountLabel = ""
  if (totals["completed"] > 500) {
    discountLabel = "VIP Discount Applied" // reassignment in conditional
  }

  return (
    <div>
      <h2>{discountLabel}</h2>
      {sorted.map((order) => (
        <OrderRow key={order.id} order={order} />
      ))}
    </div>
  )
}
```

**Correct (pure transforms enable full compiler memoization):**

```tsx
function OrderSummary({ orders }: { orders: Order[] }) {
  const sorted = [...orders].sort((a, b) => b.total - a.total)

  const totals = Object.groupBy(sorted, (order) => order.status)
  const completedTotal = (totals["completed"] ?? []).reduce(
    (sum, order) => sum + order.total,
    0
  )

  const discountLabel = completedTotal > 500 ? "VIP Discount Applied" : ""

  return (
    <div>
      <h2>{discountLabel}</h2>
      {sorted.map((order) => (
        <OrderRow key={order.id} order={order} />
      ))}
    </div>
  )
}
```

Reference: [React Compiler — How It Works](https://react.dev/learn/react-compiler)
