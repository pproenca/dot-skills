---
title: Use useTransition for Non-Blocking Updates
impact: CRITICAL
impactDescription: keeps UI responsive during heavy updates
tags: conc, useTransition, concurrent, non-blocking
---

## Use useTransition for Non-Blocking Updates

Wrap expensive state updates in `startTransition` to keep the UI responsive. React will interrupt the transition if higher-priority updates occur.

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
