---
title: Use useDeferredValue for Derived Expensive Values
impact: CRITICAL
impactDescription: prevents jank in derived computations
tags: conc, useDeferredValue, concurrent, performance
---

## Use useDeferredValue for Derived Expensive Values

Use `useDeferredValue` to defer updates to derived values that trigger expensive re-renders. The deferred value lags behind the source during heavy updates.

**Incorrect (expensive derived render blocks UI):**

```typescript
function SearchPage() {
  const [query, setQuery] = useState('')

  return (
    <div>
      <input
        value={query}
        onChange={e => setQuery(e.target.value)}
      />
      {/* SearchResults re-renders on every keystroke */}
      <SearchResults query={query} />
    </div>
  )
}

function SearchResults({ query }: { query: string }) {
  // Expensive computation runs on every character typed
  const results = useMemo(() => searchDatabase(query), [query])
  return <ResultsList results={results} />
}
```

**Correct (deferred value for expensive child):**

```typescript
import { useState, useDeferredValue } from 'react'

function SearchPage() {
  const [query, setQuery] = useState('')
  const deferredQuery = useDeferredValue(query)
  const isStale = query !== deferredQuery

  return (
    <div>
      <input
        value={query}
        onChange={e => setQuery(e.target.value)}
      />
      <div style={{ opacity: isStale ? 0.7 : 1 }}>
        <SearchResults query={deferredQuery} />
      </div>
    </div>
  )
}
// Input updates immediately, results update when React is idle
```

**Difference from useTransition:**
- `useTransition` - You control when transition starts
- `useDeferredValue` - React controls when value updates
- Use `useDeferredValue` when you don't control the state update
