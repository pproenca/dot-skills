---
title: Debounce Expensive Derived Computations
impact: HIGH
impactDescription: 50-200ms saved per keystroke in search/filter UIs
tags: render, debounce, search, filtering, performance
---

## Debounce Expensive Derived Computations

Computing derived results on every keystroke forces the main thread to process expensive operations (filtering thousands of records, scoring matches) at 30-60 events per second. Debouncing batches rapid inputs into a single computation after the user pauses typing.

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

**Correct (debounced computation runs once after typing stops):**

```tsx
import { useState, useMemo } from "react"
import { useDebouncedValue } from "./useDebouncedValue"

interface Listing {
  id: string
  title: string
  description: string
  location: string
}

function ListingSearch({ listings }: { listings: Listing[] }) {
  const [query, setQuery] = useState("")
  const debouncedQuery = useDebouncedValue(query, 300)

  const matchedListings = useMemo(() => {
    if (!debouncedQuery) return listings
    const lowerQuery = debouncedQuery.toLowerCase()
    return listings.filter(
      (listing) =>
        listing.title.toLowerCase().includes(lowerQuery) ||
        listing.description.toLowerCase().includes(lowerQuery) ||
        listing.location.toLowerCase().includes(lowerQuery)
    )
  }, [listings, debouncedQuery])

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

function useDebouncedValue<T>(value: T, delayMs: number): T {
  const [debouncedValue, setDebouncedValue] = useState(value)

  useEffect(() => {
    const timer = setTimeout(() => setDebouncedValue(value), delayMs)
    return () => clearTimeout(timer)
  }, [value, delayMs])

  return debouncedValue
}
```

Reference: [Debouncing and Throttling Explained](https://css-tricks.com/debouncing-throttling-explained-examples/)
