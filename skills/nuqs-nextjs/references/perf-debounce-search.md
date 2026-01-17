---
title: Debounce Search Input Before URL Update
impact: MEDIUM
impactDescription: reduces server requests during typing
tags: perf, debounce, search, typing, server-load
---

## Debounce Search Input Before URL Update

For search inputs with `shallow: false`, debounce the URL update to avoid hammering the server with requests on every keystroke. Keep local state for instant UI feedback.

**Incorrect (server request per keystroke):**

```tsx
'use client'
import { useQueryState, parseAsString } from 'nuqs'

export default function SearchBox() {
  const [query, setQuery] = useQueryState('q', parseAsString.withDefault('').withOptions({
    shallow: false // Every keystroke triggers server fetch
  }))

  return (
    <input
      value={query}
      onChange={e => setQuery(e.target.value)}
    />
  )
}
```

**Correct (debounced URL update):**

```tsx
'use client'
import { useState, useEffect, useTransition } from 'react'
import { useQueryState, parseAsString } from 'nuqs'

export default function SearchBox() {
  const [isLoading, startTransition] = useTransition()
  const [query, setQuery] = useQueryState('q', parseAsString.withDefault('').withOptions({
    shallow: false,
    startTransition
  }))

  // Local state for instant UI
  const [inputValue, setInputValue] = useState(query)

  // Sync URL → input when URL changes externally
  useEffect(() => {
    setInputValue(query)
  }, [query])

  // Debounce input → URL
  useEffect(() => {
    const timeout = setTimeout(() => {
      if (inputValue !== query) {
        setQuery(inputValue || null)
      }
    }, 300)
    return () => clearTimeout(timeout)
  }, [inputValue, query, setQuery])

  return (
    <div>
      <input
        value={inputValue}
        onChange={e => setInputValue(e.target.value)}
        placeholder="Search..."
      />
      {isLoading && <span>Searching...</span>}
    </div>
  )
}
```

**Alternative (useDeferredValue):**

```tsx
'use client'
import { useDeferredValue } from 'react'
import { useQueryState, parseAsString } from 'nuqs'

export default function SearchBox() {
  const [query, setQuery] = useQueryState('q', parseAsString.withDefault(''))
  const deferredQuery = useDeferredValue(query)
  const isStale = query !== deferredQuery

  return (
    <div style={{ opacity: isStale ? 0.7 : 1 }}>
      <input value={query} onChange={e => setQuery(e.target.value)} />
      <Results query={deferredQuery} />
    </div>
  )
}
```

Reference: [React useDeferredValue](https://react.dev/reference/react/useDeferredValue)
