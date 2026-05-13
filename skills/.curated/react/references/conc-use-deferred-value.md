---
title: Defer a value you don't own when it drives an expensive child re-render
impact: CRITICAL
impactDescription: prevents jank in derived computations driven by props or URL values you can't wrap in startTransition
tags: conc, deferred-value, prop-derived, expensive-child
---

## Defer a value you don't own when it drives an expensive child re-render

**Pattern intent:** when an expensive component re-renders on every change of a value you didn't set (a prop, a URL parameter, an external store), the value should be "deferred" — used as if it lagged slightly behind — so input stays responsive.

### Shapes to recognize

- Parent passes a raw `query` prop to a child that runs `searchDatabase(query)` or other O(n) work on every render — and you don't own the parent's state.
- URL parameter (`searchParams.get('q')`) drives an expensive computation directly in render or `useMemo`.
- Workaround: `setTimeout(() => setX(prop), 200)` mirror-state pattern inside the child, to "throttle" prop updates — that's a hand-rolled `useDeferredValue` with bugs.
- Workaround: pulling the prop into local `useState` plus a `useEffect` that copies it after a delay — derived state with extra steps.
- Workaround: a third-party debounce wrapping the prop in a custom hook — works, but `useDeferredValue` is the React-native answer that integrates with the scheduler.

**Pair with `useTransition` (sibling rule):** `useTransition` wraps the *cause* (the state update). `useDeferredValue` wraps the *effect* (the consumed value when you can't reach the cause). If the source is a `setState` you own, prefer `useTransition`.

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
