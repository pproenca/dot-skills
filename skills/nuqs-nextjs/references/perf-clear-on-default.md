---
title: Use clearOnDefault for Clean URLs
impact: MEDIUM
impactDescription: removes redundant parameters from URL
tags: perf, clearOnDefault, url-cleanup, defaults, seo
---

## Use clearOnDefault for Clean URLs

By default, nuqs removes parameters from the URL when they match the default value. This keeps URLs clean. Set `clearOnDefault: false` only when you need the parameter always visible.

**Default behavior (clean URLs):**

```tsx
'use client'
import { useQueryState, parseAsInteger } from 'nuqs'

export default function Pagination() {
  const [page, setPage] = useQueryState('page', parseAsInteger.withDefault(1))
  // page=1: URL is /search (clean)
  // page=2: URL is /search?page=2

  return (
    <div>
      <button onClick={() => setPage(1)}>First</button>
      <button onClick={() => setPage(p => p + 1)}>Next</button>
    </div>
  )
}
```

**When to disable (parameter always visible):**

```tsx
'use client'
import { useQueryState, parseAsString } from 'nuqs'

export default function SortControl() {
  const [sort, setSort] = useQueryState('sort', parseAsString.withDefault('relevance').withOptions({
    clearOnDefault: false // Always show sort in URL
  }))
  // Even when sort='relevance' (default):
  // URL is /search?sort=relevance

  return (
    <select value={sort} onChange={e => setSort(e.target.value)}>
      <option value="relevance">Relevance</option>
      <option value="date">Date</option>
      <option value="price">Price</option>
    </select>
  )
}
```

**Use cases for clearOnDefault: false:**
- Explicit state documentation in URL
- Analytics tracking requires all parameters
- API expects all parameters in query string
- Default value might change in future

**URL comparison:**

| Setting | Default State | Non-Default State |
|---------|--------------|-------------------|
| `clearOnDefault: true` (default) | `/search` | `/search?page=2` |
| `clearOnDefault: false` | `/search?page=1` | `/search?page=2` |

Reference: [nuqs clearOnDefault](https://nuqs.dev/docs/options)
