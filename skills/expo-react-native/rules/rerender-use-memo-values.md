---
title: Memoize Expensive Computations with useMemo
impact: MEDIUM
impactDescription: prevents redundant calculations on every render
tags: rerender, useMemo, computation, memoization
---

## Memoize Expensive Computations with useMemo

Use `useMemo` to cache expensive calculations that don't need to run on every render. This is especially important for filtering, sorting, or transforming large datasets.

**Incorrect (recalculates on every render):**

```typescript
function OrderHistory({ orders, filterStatus }) {
  // Runs on EVERY render, even when orders/filterStatus unchanged
  const filteredOrders = orders.filter(order => order.status === filterStatus)
  const sortedOrders = filteredOrders.sort((a, b) =>
    new Date(b.createdAt) - new Date(a.createdAt)
  )
  const totalAmount = sortedOrders.reduce((sum, order) => sum + order.total, 0)

  return (
    <View>
      <Text>Total: ${totalAmount}</Text>
      <FlashList data={sortedOrders} renderItem={OrderRow} />
    </View>
  )
}
```

**Correct (memoized computations):**

```typescript
function OrderHistory({ orders, filterStatus }) {
  const filteredOrders = useMemo(() =>
    orders.filter(order => order.status === filterStatus),
    [orders, filterStatus]
  )

  const sortedOrders = useMemo(() =>
    [...filteredOrders].sort((a, b) =>
      new Date(b.createdAt) - new Date(a.createdAt)
    ),
    [filteredOrders]
  )

  const totalAmount = useMemo(() =>
    sortedOrders.reduce((sum, order) => sum + order.total, 0),
    [sortedOrders]
  )

  return (
    <View>
      <Text>Total: ${totalAmount}</Text>
      <FlashList data={sortedOrders} renderItem={OrderRow} />
    </View>
  )
}
```

**Memoize object/array props to prevent child re-renders:**

```typescript
function ChartScreen({ data }) {
  // Without useMemo, new object reference every render
  const chartConfig = useMemo(() => ({
    backgroundColor: '#ffffff',
    backgroundGradientFrom: '#ffffff',
    backgroundGradientTo: '#ffffff',
    color: (opacity = 1) => `rgba(0, 122, 255, ${opacity})`,
  }), [])

  const chartData = useMemo(() => ({
    labels: data.map(d => d.label),
    datasets: [{ data: data.map(d => d.value) }],
  }), [data])

  return <LineChart data={chartData} chartConfig={chartConfig} />
}
```

**When to use useMemo:**
- Filtering/sorting large arrays (100+ items)
- Complex calculations (aggregations, transformations)
- Creating object/array props for memoized children
- Derived state from props

**When NOT to use useMemo:**
- Simple calculations
- Primitives (strings, numbers, booleans)
- Values that change every render anyway

Reference: [React useMemo Documentation](https://react.dev/reference/react/useMemo)
