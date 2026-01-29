---
title: Memoize Expensive Computed Selectors
impact: HIGH
impactDescription: prevents redundant computation on every render
tags: select, memoization, performance, computation
---

## Memoize Expensive Computed Selectors

When selectors perform expensive computations, memoize the result to avoid recalculating on every render. Combine `useMemo` with atomic selectors for optimal performance.

**Incorrect (expensive computation on every render):**

```typescript
function OrderSummary() {
  const orders = useOrderStore((s) => s.orders)

  // Recalculates on EVERY render, even if orders unchanged
  const stats = {
    total: orders.reduce((sum, o) => sum + o.total, 0),
    count: orders.length,
    average: orders.length > 0
      ? orders.reduce((sum, o) => sum + o.total, 0) / orders.length
      : 0,
    byStatus: orders.reduce((acc, o) => {
      acc[o.status] = (acc[o.status] || 0) + 1
      return acc
    }, {} as Record<string, number>),
  }

  return <StatsDisplay stats={stats} />
}
```

**Correct (memoized computation):**

```typescript
function OrderSummary() {
  const orders = useOrderStore((s) => s.orders)

  // Only recalculates when orders array changes
  const stats = useMemo(() => ({
    total: orders.reduce((sum, o) => sum + o.total, 0),
    count: orders.length,
    average: orders.length > 0
      ? orders.reduce((sum, o) => sum + o.total, 0) / orders.length
      : 0,
    byStatus: orders.reduce((acc, o) => {
      acc[o.status] = (acc[o.status] || 0) + 1
      return acc
    }, {} as Record<string, number>),
  }), [orders])

  return <StatsDisplay stats={stats} />
}
```

**Alternative (reusable computed selector hook):**

```typescript
const useOrderStats = () => {
  const orders = useOrderStore((s) => s.orders)

  return useMemo(() => ({
    total: orders.reduce((sum, o) => sum + o.total, 0),
    count: orders.length,
    average: orders.length > 0
      ? orders.reduce((sum, o) => sum + o.total, 0) / orders.length
      : 0,
  }), [orders])
}

// Multiple components can reuse
function OrderSummary() {
  const stats = useOrderStats()
  return <StatsDisplay stats={stats} />
}
```

**Benefits:**
- Expensive computations only run when dependencies change
- React's useMemo integrates naturally with Zustand selectors
- Reusable computed hooks share the pattern

Reference: [Zustand Documentation](https://zustand.docs.pmnd.rs/)
