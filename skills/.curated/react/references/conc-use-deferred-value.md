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

**When to use useDeferredValue vs useTransition:**

| Scenario | Use |
|----------|-----|
| You own the state update (e.g., `setQuery`) | `useTransition` — wrap the setter in `startTransition` |
| Value comes from props, URL, or external source | `useDeferredValue` — defer the received value |
| Tab/route navigation | `useTransition` — wrap the navigation in `startTransition` |
| Expensive child re-render from parent state | `useDeferredValue` — defer the prop passed to the child |

**Key difference:** `useTransition` wraps the **cause** (the state update). `useDeferredValue` wraps the **effect** (the value that triggers expensive work). Use `useDeferredValue` when you can't wrap the state update — e.g., the value comes from a parent component or a URL parameter you don't control.
