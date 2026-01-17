---
title: Use useMemo for Expensive Calculations
impact: MEDIUM
impactDescription: skips expensive recalculation on re-renders
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

**Note:** With React Compiler (React 19+), manual memoization becomes less necessary as the compiler handles it automatically.
