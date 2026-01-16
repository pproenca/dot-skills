---
title: Use useDeferredValue for Non-Urgent Updates
impact: MEDIUM-HIGH
impactDescription: maintains <100ms input latency during expensive renders
tags: state, useDeferredValue, concurrent, performance
---

## Use useDeferredValue for Non-Urgent Updates

The `useDeferredValue` hook lets you defer expensive re-renders while keeping the UI responsive. High-priority updates (like typing) happen immediately while heavy computations are deferred.

**Incorrect (typing feels sluggish):**

```tsx
function SearchPage() {
  const [query, setQuery] = useState('')

  // Heavy filtering blocks typing
  const filteredResults = products.filter(p =>
    p.name.toLowerCase().includes(query.toLowerCase())
  )  // 10,000 items = sluggish

  return (
    <div>
      <input
        value={query}
        onChange={e => setQuery(e.target.value)}
        placeholder="Search..."
      />
      <ProductGrid products={filteredResults} />
    </div>
  )
}
```

**Correct (typing stays responsive):**

```tsx
function SearchPage() {
  const [query, setQuery] = useState('')
  const deferredQuery = useDeferredValue(query)

  // Deferred filter doesn't block input
  const filteredResults = products.filter(p =>
    p.name.toLowerCase().includes(deferredQuery.toLowerCase())
  )

  const isStale = query !== deferredQuery

  return (
    <div>
      <input
        value={query}
        onChange={e => setQuery(e.target.value)}
        placeholder="Search..."
      />
      <div style={{ opacity: isStale ? 0.7 : 1 }}>
        <ProductGrid products={filteredResults} />
      </div>
    </div>
  )
}
```

**With memo for maximum benefit:**

```tsx
function SearchPage() {
  const [query, setQuery] = useState('')
  const deferredQuery = useDeferredValue(query)

  return (
    <div>
      <input value={query} onChange={e => setQuery(e.target.value)} />
      <MemoizedProductGrid query={deferredQuery} />
    </div>
  )
}

const MemoizedProductGrid = memo(function ProductGrid({ query }: { query: string }) {
  const filtered = products.filter(p =>
    p.name.toLowerCase().includes(query.toLowerCase())
  )
  return <Grid products={filtered} />
})
```

Reference: [useDeferredValue](https://react.dev/reference/react/useDeferredValue)
