---
title: Use history:push for Navigation-Like State
impact: MEDIUM
impactDescription: enables back button for state navigation
tags: history, push, navigation, back-button, ux
---

## Use history:push for Navigation-Like State

Use `history: 'push'` when state changes represent navigation that users would expect to undo with the back button (pagination, tabs, modal state).

**Incorrect (replace loses navigation history):**

```tsx
'use client'
import { useQueryState, parseAsInteger } from 'nuqs'

export default function Pagination() {
  const [page, setPage] = useQueryState('page', parseAsInteger.withDefault(1))
  // history: 'replace' (default)
  // User clicks page 1 → 2 → 3 → back button → leaves site!

  return (
    <nav>
      <button onClick={() => setPage(p => p - 1)}>Previous</button>
      <span>Page {page}</span>
      <button onClick={() => setPage(p => p + 1)}>Next</button>
    </nav>
  )
}
```

**Correct (push enables back navigation):**

```tsx
'use client'
import { useQueryState, parseAsInteger } from 'nuqs'

export default function Pagination() {
  const [page, setPage] = useQueryState('page', parseAsInteger.withDefault(1).withOptions({
    history: 'push'
  }))
  // User clicks page 1 → 2 → 3 → back button → page 2

  return (
    <nav>
      <button onClick={() => setPage(p => p - 1)}>Previous</button>
      <span>Page {page}</span>
      <button onClick={() => setPage(p => p + 1)}>Next</button>
    </nav>
  )
}
```

**Typical use cases for history:push:**
- Pagination
- Tab selection
- Modal open/close state
- Step-by-step wizards
- Filter panel expansion

**Mix modes when needed:**

```tsx
const [page, setPage] = useQueryState('page', parseAsInteger.withDefault(1).withOptions({
  history: 'push'
}))

// Programmatic navigation pushes
setPage(5)

// But "reset" replaces to avoid back-button spam
setPage(1, { history: 'replace' })
```

Reference: [nuqs History Option](https://nuqs.dev/docs/options)
