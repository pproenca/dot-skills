---
title: Memoize from a measured baseline — don't pre-wrap every value and callback in useMemo/useCallback
impact: MEDIUM
impactDescription: removes 0.1-0.5ms per-render overhead per unnecessary memo, declutters the code, defers to React Compiler v1.0 where present
tags: memo, premature-memoization, profile-first, compiler-aware
---

## Memoize from a measured baseline — don't pre-wrap every value and callback in useMemo/useCallback

**Pattern intent:** memoization has costs (comparison, retention, code noise). The right time to introduce it is when a profile shows a measurable problem — not when writing the component. With React Compiler v1.0, the calculus shifts further: most cases are handled automatically and manual memoization adds noise.

### Shapes to recognize

- `const x = useMemo(() => a + b, [a, b])` — primitive add, costs more than the recomputation.
- `useCallback` wrapping a handler with no consumer that cares about reference stability.
- `useMemo` wrapping the result of `array.length` or a string concatenation.
- A new project with `useCallback`/`useMemo` on every handler/value "by policy" — the policy predates the compiler.
- A code review comment "wrap this in useMemo for performance" with no profiling evidence — cargo-cult.
- A component that's `React.memo`'d but receives a non-stable prop (`{...rest}` spread, inline object) — the memo is paid for and doesn't work.

The canonical resolution: leave memoization off until React Profiler shows a hot path. If React Compiler is enabled, lean on it for the common cases (see [`memo-compiler.md`](memo-compiler.md)). Reach for manual memo when (a) profile says yes, or (b) the value crosses into a memoed boundary that needs reference stability.

**Incorrect (memoizing everything):**

```typescript
function SimpleList({ items }: { items: string[] }) {
  // Unnecessary - simple calculation
  const count = useMemo(() => items.length, [items])

  // Unnecessary - string concatenation is fast
  const title = useMemo(() => `${count} items`, [count])

  // Unnecessary - simple callback on simple component
  const handleClick = useCallback((id: string) => {
    console.log(id)
  }, [])

  return (
    <ul>
      <li>{title}</li>
      {items.map(item => (
        <li key={item} onClick={() => handleClick(item)}>{item}</li>
      ))}
    </ul>
  )
}
// Memoization overhead exceeds the cost it's trying to save
```

**Correct (memoize only what's needed):**

```typescript
function SimpleList({ items }: { items: string[] }) {
  // No memoization needed for cheap operations
  const count = items.length
  const title = `${count} items`

  return (
    <ul>
      <li>{title}</li>
      {items.map(item => (
        <li key={item}>{item}</li>
      ))}
    </ul>
  )
}
```

**When to memoize:**
- React Profiler shows component is slow
- Large arrays (1000+ items) with expensive operations
- Passing callbacks to many memoized children
- Complex object creation passed as props

**When NOT to memoize:**
- Simple calculations (length, concatenation)
- Components that render fast (<16ms)
- Dependencies change on every render
- Development-only "optimization"
