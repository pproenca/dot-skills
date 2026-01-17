---
title: Memoize Components Using URL State
impact: MEDIUM
impactDescription: prevents unnecessary re-renders on URL changes
tags: perf, memo, re-renders, optimization, react
---

## Memoize Components Using URL State

When URL state changes, all components using that state re-render. Use `React.memo` and extract URL-dependent logic to prevent cascading re-renders.

**Incorrect (entire page re-renders):**

```tsx
'use client'
import { useQueryState, parseAsString } from 'nuqs'

export default function SearchPage() {
  const [query, setQuery] = useQueryState('q', parseAsString.withDefault(''))

  return (
    <div>
      <SearchInput query={query} setQuery={setQuery} />
      <ExpensiveSidebar /> {/* Re-renders on every query change */}
      <ResultsList query={query} />
    </div>
  )
}

function ExpensiveSidebar() {
  // Heavy computation that doesn't need query
  return <aside>...</aside>
}
```

**Correct (memoized components):**

```tsx
'use client'
import { memo } from 'react'
import { useQueryState, parseAsString } from 'nuqs'

export default function SearchPage() {
  const [query, setQuery] = useQueryState('q', parseAsString.withDefault(''))

  return (
    <div>
      <SearchInput query={query} setQuery={setQuery} />
      <ExpensiveSidebar /> {/* Memoized - doesn't re-render */}
      <ResultsList query={query} />
    </div>
  )
}

const ExpensiveSidebar = memo(function ExpensiveSidebar() {
  return <aside>...</aside>
})
```

**Alternative (extract hook usage):**

```tsx
'use client'
import { useQueryState, parseAsString } from 'nuqs'

// Only this component re-renders on query change
function SearchSection() {
  const [query, setQuery] = useQueryState('q', parseAsString.withDefault(''))

  return (
    <>
      <SearchInput query={query} setQuery={setQuery} />
      <ResultsList query={query} />
    </>
  )
}

export default function SearchPage() {
  return (
    <div>
      <SearchSection />
      <ExpensiveSidebar /> {/* Not affected by query changes */}
    </div>
  )
}
```

Reference: [React memo](https://react.dev/reference/react/memo)
