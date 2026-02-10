---
title: Use useMemo for Expensive Calculations
impact: MEDIUM
impactDescription: skips O(n) recalculations on re-renders with unchanged dependencies
tags: memo, useMemo, performance, calculation
---

## Use useMemo for Expensive Calculations

Wrap expensive computations in useMemo to cache results between renders. Only recalculate when dependencies change.

**Incorrect (recalculates on every render):**

```typescript
function AnalyticsChart({ data, filter }: { data: DataPoint[]; filter: Filter }) {
  // Expensive aggregation runs on every render
  const aggregated = data
    .filter(d => matchesFilter(d, filter))
    .reduce((acc, d) => aggregate(acc, d), initialAcc)

  return <Chart data={aggregated} />
}
// Parent re-render → expensive calculation runs
```

**Correct (memoized calculation):**

```typescript
import { useMemo } from 'react'

function AnalyticsChart({ data, filter }: { data: DataPoint[]; filter: Filter }) {
  const aggregated = useMemo(() => {
    return data
      .filter(d => matchesFilter(d, filter))
      .reduce((acc, d) => aggregate(acc, d), initialAcc)
  }, [data, filter])

  return <Chart data={aggregated} />
}
// Only recalculates when data or filter changes
```

**When to use useMemo:**
- Large array transformations (filter, map, reduce)
- Complex object computations
- Expensive algorithms (sorting, searching)

**When NOT to use useMemo:**
- Simple calculations (addition, string concatenation)
- When the component rarely re-renders
- When dependencies change on every render

**Note:** If using [React Compiler v1.0+](https://react.dev/blog/2025/10/07/react-compiler-1) (works with React 17+), useMemo is handled automatically. Use manual useMemo only when the compiler can't optimize your case.
