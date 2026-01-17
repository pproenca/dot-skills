---
title: Handle Browser Back/Forward Navigation
impact: MEDIUM
impactDescription: ensures state stays in sync with URL on navigation
tags: history, back-button, forward, popstate, sync
---

## Handle Browser Back/Forward Navigation

nuqs automatically syncs state with URL when users navigate with browser back/forward buttons. Ensure your UI handles these state changes correctly.

**Automatic sync (works out of the box):**

```tsx
'use client'
import { useQueryState, parseAsInteger } from 'nuqs'

export default function Pagination() {
  const [page, setPage] = useQueryState('page', parseAsInteger.withDefault(1).withOptions({
    history: 'push'
  }))
  // User: page 1 → 2 → 3
  // Back button: page becomes 2 (automatic)
  // UI re-renders with new page value

  return (
    <div>
      <p>Page {page}</p>
      <button onClick={() => setPage(p => p + 1)}>Next</button>
    </div>
  )
}
```

**Handling side effects on navigation:**

```tsx
'use client'
import { useEffect } from 'react'
import { useQueryState, parseAsInteger } from 'nuqs'

export default function Pagination() {
  const [page, setPage] = useQueryState('page', parseAsInteger.withDefault(1).withOptions({
    history: 'push'
  }))

  // Side effect runs on any page change (including back/forward)
  useEffect(() => {
    analytics.track('page_view', { page })
  }, [page])

  return <p>Page {page}</p>
}
```

**With loading states:**

```tsx
'use client'
import { useTransition } from 'react'
import { useQueryState, parseAsInteger } from 'nuqs'

export default function Pagination() {
  const [isLoading, startTransition] = useTransition()
  const [page, setPage] = useQueryState('page', parseAsInteger.withDefault(1).withOptions({
    history: 'push',
    shallow: false,
    startTransition
  }))
  // isLoading updates on back/forward too

  return (
    <div style={{ opacity: isLoading ? 0.5 : 1 }}>
      <p>Page {page}</p>
    </div>
  )
}
```

**Caveat with local state:**

```tsx
// If you have local state derived from URL, sync it
const [page] = useQueryState('page', parseAsInteger.withDefault(1))
const [localPage, setLocalPage] = useState(page)

useEffect(() => {
  setLocalPage(page) // Sync on back/forward
}, [page])
```

Reference: [nuqs Documentation](https://nuqs.dev/docs)
