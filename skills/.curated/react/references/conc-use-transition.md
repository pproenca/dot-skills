---
title: Mark expensive state updates as low-priority so input stays responsive
impact: CRITICAL
impactDescription: maintains <50ms input latency during heavy state updates by marking the heavy work as interruptible
tags: conc, transition, low-priority-update, input-blocking
---

## Mark expensive state updates as low-priority so input stays responsive

**Pattern intent:** when one user action triggers two updates — a fast one (the input value the user just typed) and a slow one (a filter, sort, or route render) — the slow one should be marked interruptible so React can keep input responsive.

### Shapes to recognize

- `onChange` handler computes a 1k+ item `.filter`/`.sort` inline and calls `setResults(...)` synchronously before returning.
- Router-style `setPage(next)` that triggers a heavy data render with no transition — the click feels sluggish before the next page appears.
- Tab switcher where the tab indicator visibly lags the click because the new tab's render is expensive.
- Workaround: `setTimeout(() => setResults(...), 0)` or `requestIdleCallback(() => setResults(...))` to "yield to the browser" — a hand-rolled scheduler that doesn't integrate with Suspense or stale-content rendering.
- Workaround: a debounced setState that delays even fast updates — fixes janky filtering at the cost of laggy typing.

**Pair with `useDeferredValue` (sibling rule):** wrap with `startTransition` when you *own* the state update. Use `useDeferredValue` when you don't (prop or URL-driven).

**Incorrect (blocking state update):**

```typescript
function SearchResults() {
  const [query, setQuery] = useState('')
  const [results, setResults] = useState([])

  function handleSearch(value: string) {
    setQuery(value)
    // Expensive filtering blocks UI
    const filtered = filterResults(allItems, value)  // 1000+ items
    setResults(filtered)
  }

  return (
    <div>
      <input onChange={e => handleSearch(e.target.value)} />
      {/* Input feels sluggish during filtering */}
      <ResultsList results={results} />
    </div>
  )
}
```

**Correct (non-blocking with useTransition):**

```typescript
import { useState, useTransition } from 'react'

function SearchResults() {
  const [query, setQuery] = useState('')
  const [results, setResults] = useState([])
  const [isPending, startTransition] = useTransition()

  function handleSearch(value: string) {
    setQuery(value)  // High priority - updates immediately
    startTransition(() => {
      // Low priority - can be interrupted
      const filtered = filterResults(allItems, value)
      setResults(filtered)
    })
  }

  return (
    <div>
      <input onChange={e => handleSearch(e.target.value)} />
      {isPending && <Spinner />}
      <ResultsList results={results} />
    </div>
  )
}
// Input stays responsive while results update in background
```

**When to use:**
- Filtering large lists
- Tab switches with heavy content
- Route transitions
- Any expensive re-render that shouldn't block input
