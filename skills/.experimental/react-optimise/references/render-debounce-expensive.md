---
title: Debounce Expensive Derived Computations
impact: HIGH
impactDescription: 50-200ms saved per keystroke in search/filter UIs
tags: render, debounce, search, filtering, performance
---

## Debounce Expensive Derived Computations

Computing derived results on every keystroke forces the main thread to process expensive operations (filtering thousands of records, scoring matches) at 30-60 events per second. `useDeferredValue` tells React to defer the expensive re-render to a lower priority, keeping the input responsive while the filtered results update in the background.

**Incorrect (filters 10,000 records on every keystroke):**

```tsx
import { useState } from "react"

interface Listing {
  id: string
  title: string
  description: string
  location: string
}

function ListingSearch({ listings }: { listings: Listing[] }) {
  const [query, setQuery] = useState("")

  // runs on every keystroke — blocks UI for 50-200ms per invocation
  const matchedListings = listings.filter(
    (listing) =>
      listing.title.toLowerCase().includes(query.toLowerCase()) ||
      listing.description.toLowerCase().includes(query.toLowerCase()) ||
      listing.location.toLowerCase().includes(query.toLowerCase())
  )

  return (
    <div>
      <input
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        placeholder="Search listings..."
      />
      <ResultsList listings={matchedListings} />
    </div>
  )
}
```

**Correct (deferred computation keeps input responsive):**

```tsx
import { useState, useDeferredValue, useMemo } from "react"

interface Listing {
  id: string
  title: string
  description: string
  location: string
}

function ListingSearch({ listings }: { listings: Listing[] }) {
  const [query, setQuery] = useState("")
  const deferredQuery = useDeferredValue(query)

  const matchedListings = useMemo(() => {
    if (!deferredQuery) return listings
    const lowerQuery = deferredQuery.toLowerCase()
    return listings.filter(
      (listing) =>
        listing.title.toLowerCase().includes(lowerQuery) ||
        listing.description.toLowerCase().includes(lowerQuery) ||
        listing.location.toLowerCase().includes(lowerQuery)
    )
  }, [listings, deferredQuery])

  return (
    <div>
      <input
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        placeholder="Search listings..."
      />
      <ResultsList listings={matchedListings} />
    </div>
  )
}
```

**Alternative (setTimeout debounce for fixed-delay requirements):**

When you need a guaranteed minimum delay (e.g., rate-limiting API calls), use a timeout-based debounce instead of `useDeferredValue`:

```tsx
function useDebouncedValue<T>(value: T, delayMs: number): T {
  const [debouncedValue, setDebouncedValue] = useState(value)
  useEffect(() => {
    const timer = setTimeout(() => setDebouncedValue(value), delayMs)
    return () => clearTimeout(timer)
  }, [value, delayMs])
  return debouncedValue
}
```

Reference: [React — useDeferredValue](https://react.dev/reference/react/useDeferredValue)
