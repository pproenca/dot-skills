---
title: Avoid Premature Memoization
impact: MEDIUM
impactDescription: memoization has overhead, measure first
tags: memo, premature, profiling, performance
---

## Avoid Premature Memoization

Memoization has costs: storing previous values and comparing. Don't memoize everything - profile first and optimize bottlenecks.

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
