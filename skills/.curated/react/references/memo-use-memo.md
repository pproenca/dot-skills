---
title: Cache a computation between renders only when its inputs are stable and the work is measurably expensive
impact: MEDIUM
impactDescription: skips O(n) recalculations on re-renders whose dependencies haven't changed — saves time on hot paths, costs time on cold ones
tags: memo, useMemo, expensive-calc, dep-stability
---

## Cache a computation between renders only when its inputs are stable and the work is measurably expensive

**Pattern intent:** `useMemo` is a render-time cache keyed on dep identity. It pays off when (a) the computation is expensive enough to matter, and (b) deps are reference-stable enough to actually hit the cache. Both halves matter.

### Shapes to recognize

- `useMemo(() => a + b, [a, b])` — trivial expression; the memo overhead exceeds the work.
- `useMemo(() => items.map(transform), [items])` where `items` comes in as an inline parent-recreated array — deps unstable, cache never hits.
- A `useMemo` whose body internally creates an object literal and another `useMemo` consumes it — chain of unstable inputs.
- A `useMemo` "for safety" wrapping a `JSX` expression — the value isn't reused; the memo doesn't save renders.
- `useMemo` used to "stabilize" a result of `useState` — but `useState` values are already stable until you call the setter; the memo is redundant.
- A `useMemo` returning a Promise inside a Client Component to pass to `use()` — recreates on every render; better to lift creation to a Server Component (see [`data-use-hook.md`](data-use-hook.md)).

The canonical resolution: profile first; reach for `useMemo` when (a) the work is measurably hot, *and* (b) the deps are reference-stable enough to hit the cache. With React Compiler v1.0, most cases collapse to plain expressions.

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
