---
title: Provide Immediate Visual Feedback for Input
impact: CRITICAL
impactDescription: <100ms response feels instant
tags: input, feedback, latency, ux, responsiveness
---

## Provide Immediate Visual Feedback for Input

Respond to user input within 100ms. Users perceive delays over 100ms as lag. Show immediate visual feedback even if the underlying operation takes longer.

**Incorrect (no feedback until operation completes):**

```typescript
import { useInput, Text, Box } from 'ink'
import { useState } from 'react'

function SearchInput() {
  const [query, setQuery] = useState('')
  const [results, setResults] = useState<string[]>([])

  useInput(async (input) => {
    if (input && !input.includes('\x1b')) {
      const newQuery = query + input
      // User sees nothing until search completes
      const searchResults = await performSearch(newQuery)  // 500ms
      setQuery(newQuery)
      setResults(searchResults)
    }
  })

  return <Text>Results: {results.length}</Text>
}
```

**Correct (immediate feedback, async results):**

```typescript
import { useInput, Text, Box } from 'ink'
import { useState, useEffect } from 'react'

function SearchInput() {
  const [query, setQuery] = useState('')
  const [results, setResults] = useState<string[]>([])
  const [isSearching, setIsSearching] = useState(false)

  useInput((input) => {
    if (input && !input.includes('\x1b')) {
      setQuery(q => q + input)  // Immediate update
    }
  })

  useEffect(() => {
    if (!query) return
    setIsSearching(true)

    const timer = setTimeout(async () => {
      const searchResults = await performSearch(query)
      setResults(searchResults)
      setIsSearching(false)
    }, 150)  // Debounce search

    return () => clearTimeout(timer)
  }, [query])

  return (
    <Box flexDirection="column">
      <Text>Query: {query}</Text>
      <Text dimColor>{isSearching ? 'Searching...' : `${results.length} results`}</Text>
    </Box>
  )
}
```

**Benefits:**
- Input appears instantly (query updates synchronously)
- Visual indicator shows work in progress
- Debouncing prevents excessive API calls

Reference: [clig.dev - Responsiveness](https://clig.dev/#responsiveness)
