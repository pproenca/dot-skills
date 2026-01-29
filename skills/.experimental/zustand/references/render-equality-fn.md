---
title: Provide Custom Equality Functions When Needed
impact: HIGH
impactDescription: reduces re-renders by 50-90% for complex selectors
tags: render, equality, comparison, performance
---

## Provide Custom Equality Functions When Needed

For complex comparison logic beyond shallow equality, provide a custom equality function as the second argument to the store hook.

**Incorrect (no equality function, always re-renders):**

```typescript
function ExpensiveChart() {
  // Deep object, strict equality always fails
  const chartData = useAnalyticsStore((state) => ({
    labels: state.labels,
    datasets: state.datasets.map((d) => ({
      data: d.values,
      label: d.name,
    })),
  }))
  // Re-renders on every state change
  return <Chart data={chartData} />
}
```

**Correct (custom equality function):**

```typescript
import { shallow } from 'zustand/shallow'

function ExpensiveChart() {
  const chartData = useAnalyticsStore(
    (state) => ({
      labels: state.labels,
      datasets: state.datasets.map((d) => ({
        data: d.values,
        label: d.name,
      })),
    }),
    // Custom comparison: only re-render if labels or dataset count changes
    (oldData, newData) =>
      shallow(oldData.labels, newData.labels) &&
      oldData.datasets.length === newData.datasets.length &&
      oldData.datasets.every(
        (d, i) => shallow(d.data, newData.datasets[i].data)
      )
  )

  return <Chart data={chartData} />
}
```

**Alternative (deep equality with lodash):**

```typescript
import isEqual from 'lodash/isEqual'

function ExpensiveChart() {
  const chartData = useAnalyticsStore(
    (state) => ({
      labels: state.labels,
      datasets: state.datasets,
    }),
    isEqual // Deep equality check
  )

  return <Chart data={chartData} />
}
```

**When to use custom equality:**
- Deep nested objects where shallow comparison isn't enough
- Performance-critical components with complex state
- When you need to ignore certain property changes

Reference: [Zustand Documentation](https://zustand.docs.pmnd.rs/)
