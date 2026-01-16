---
title: Use Manual Memoization for Effect Dependencies
impact: MEDIUM-HIGH
impactDescription: prevents unwanted effect re-runs with memoized dependencies
tags: compiler, effects, dependencies, useMemo, useCallback
---

## Use Manual Memoization for Effect Dependencies

React Compiler's memoization is optimized for rendering, not for effect dependency identity. When a value is used as an effect dependency, manual memoization may still be needed to prevent unwanted re-runs.

**Incorrect (effect runs too often):**

```tsx
function SearchResults({ query, filters }: Props) {
  const searchParams = { query, ...filters }  // New object every render

  useEffect(() => {
    fetchResults(searchParams)  // Runs every render!
  }, [searchParams])

  return <Results />
}
```

**Correct (stable dependency):**

```tsx
function SearchResults({ query, filters }: Props) {
  const searchParams = useMemo(
    () => ({ query, ...filters }),
    [query, filters]  // Only changes when inputs change
  )

  useEffect(() => {
    fetchResults(searchParams)  // Runs only when params change
  }, [searchParams])

  return <Results />
}
```

**Alternative (primitive dependencies):**

```tsx
function SearchResults({ query, filters }: Props) {
  useEffect(() => {
    // Inline the object creation in the effect
    const searchParams = { query, ...filters }
    fetchResults(searchParams)
  }, [query, filters.category, filters.sort])  // Primitives as deps

  return <Results />
}
```

**When manual memoization helps:**
- Objects/arrays used as effect dependencies
- Callbacks passed to third-party libraries with identity checks
- Values compared with `===` by external code

Reference: [React Compiler and Effects](https://react.dev/learn/react-compiler/introduction#how-does-react-compiler-work)
