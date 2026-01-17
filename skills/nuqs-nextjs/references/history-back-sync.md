---
title: Handle Browser Back/Forward Navigation
impact: MEDIUM
impactDescription: prevents stale UI after browser navigation
tags: history, back-button, forward, popstate, sync
---

## Handle Browser Back/Forward Navigation

nuqs automatically syncs state with URL when users navigate with browser back/forward buttons. Ensure your UI handles these state changes correctly.

**Incorrect (local state gets out of sync):**

```tsx
'use client'
import { useState, useEffect } from 'react'
import { useQueryState, parseAsInteger } from 'nuqs'

export default function Pagination() {
  const [urlPage] = useQueryState('page', parseAsInteger.withDefault(1))
  const [localPage, setLocalPage] = useState(urlPage)
  // User navigates back - urlPage updates but localPage doesn't!

  return <p>Page {localPage}</p> // Shows stale value
}
```

**Correct (use URL state directly):**

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

Reference: [nuqs Documentation](https://nuqs.dev/docs)
