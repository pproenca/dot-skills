---
title: Use history:replace for Ephemeral State
impact: MEDIUM
impactDescription: prevents history pollution from frequent updates
tags: history, replace, ephemeral, typing, slider
---

## Use history:replace for Ephemeral State

Use `history: 'replace'` (default) for state that changes frequently or represents intermediate values users wouldn't want to navigate through (typing, sliders, filters).

**Correct (replace for typing):**

```tsx
'use client'
import { useQueryState, parseAsString } from 'nuqs'

export default function SearchBox() {
  const [query, setQuery] = useQueryState('q', parseAsString.withDefault(''))
  // history: 'replace' (default)
  // Typing "react" doesn't create 5 history entries

  return (
    <input
      value={query}
      onChange={e => setQuery(e.target.value)}
      placeholder="Search..."
    />
  )
}
```

**Incorrect (push for typing):**

```tsx
'use client'
import { useQueryState, parseAsString } from 'nuqs'

export default function SearchBox() {
  const [query, setQuery] = useQueryState('q', parseAsString.withDefault('').withOptions({
    history: 'push' // Don't do this!
  }))
  // Typing "react" creates entries: r, re, rea, reac, react
  // Back button is unusable

  return (
    <input
      value={query}
      onChange={e => setQuery(e.target.value)}
    />
  )
}
```

**Typical use cases for history:replace (default):**
- Search input text
- Slider/range values
- Real-time filter changes
- Sort order selection
- Any rapidly-changing state

**Hybrid pattern (replace during typing, push on submit):**

```tsx
'use client'
import { useState } from 'react'
import { useQueryState, parseAsString } from 'nuqs'

export default function SearchForm() {
  const [query, setQuery] = useQueryState('q', parseAsString.withDefault(''))
  const [input, setInput] = useState(query)

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    setQuery(input, { history: 'push' }) // Push on explicit submit
  }

  return (
    <form onSubmit={handleSubmit}>
      <input value={input} onChange={e => setInput(e.target.value)} />
      <button type="submit">Search</button>
    </form>
  )
}
```

Reference: [nuqs History Option](https://nuqs.dev/docs/options)
