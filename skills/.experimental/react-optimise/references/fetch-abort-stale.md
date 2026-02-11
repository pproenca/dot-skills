---
title: Abort Stale Requests on Navigation or Re-fetch
impact: HIGH
impactDescription: prevents stale data display, eliminates race conditions
tags: fetch, abort-controller, race-condition, cleanup, useEffect
---

## Abort Stale Requests on Navigation or Re-fetch

When a user types quickly in a search field or navigates between pages, earlier requests may resolve after later ones. Without aborting stale requests, the UI displays outdated results that overwrite fresh data. AbortController cancels superseded requests and prevents race conditions.

**Incorrect (stale response overwrites fresh data):**

```tsx
import { useEffect, useState } from "react"

interface SearchResult {
  id: string
  title: string
  relevanceScore: number
}

function PropertySearch({ query }: { query: string }) {
  const [results, setResults] = useState<SearchResult[]>([])

  useEffect(() => {
    if (!query) return

    // slow "apartment" request (500ms) resolves AFTER fast "apartment london" (200ms)
    fetch(`/api/search?q=${encodeURIComponent(query)}`)
      .then((response) => response.json())
      .then((data) => setResults(data.results))
  }, [query])

  return (
    <ul>
      {results.map((result) => (
        <li key={result.id}>{result.title} ({result.relevanceScore})</li>
      ))}
    </ul>
  )
}
```

**Correct (stale requests aborted on re-fetch):**

```tsx
import { useEffect, useState } from "react"

interface SearchResult {
  id: string
  title: string
  relevanceScore: number
}

function PropertySearch({ query }: { query: string }) {
  const [results, setResults] = useState<SearchResult[]>([])

  useEffect(() => {
    if (!query) return

    const controller = new AbortController()

    fetch(`/api/search?q=${encodeURIComponent(query)}`, {
      signal: controller.signal,
    })
      .then((response) => response.json())
      .then((data) => setResults(data.results))
      .catch((error) => {
        if (error.name !== "AbortError") throw error // ignore aborted requests
      })

    return () => controller.abort() // cancels previous request when query changes
  }, [query])

  return (
    <ul>
      {results.map((result) => (
        <li key={result.id}>{result.title} ({result.relevanceScore})</li>
      ))}
    </ul>
  )
}
```

Reference: [MDN — AbortController](https://developer.mozilla.org/en-US/docs/Web/API/AbortController)
