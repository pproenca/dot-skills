---
title: Control Scroll Behavior on URL Changes
impact: MEDIUM
impactDescription: prevents unwanted scroll jumps on state changes
tags: history, scroll, ux, navigation, viewport
---

## Control Scroll Behavior on URL Changes

By default, nuqs doesn't scroll on URL changes. Use the `scroll` option to control whether state changes scroll to the top of the page.

**Default (no scroll):**

```tsx
'use client'
import { useQueryState, parseAsString } from 'nuqs'

export default function FilterPanel() {
  const [filter, setFilter] = useQueryState('filter', parseAsString.withDefault(''))
  // scroll: false (default)
  // User stays at current scroll position when filtering

  return (
    <select value={filter} onChange={e => setFilter(e.target.value)}>
      <option value="">All</option>
      <option value="active">Active</option>
      <option value="completed">Completed</option>
    </select>
  )
}
```

**Enable scroll for navigation-like changes:**

```tsx
'use client'
import { useQueryState, parseAsInteger } from 'nuqs'

export default function Pagination() {
  const [page, setPage] = useQueryState('page', parseAsInteger.withDefault(1).withOptions({
    scroll: true, // Scroll to top on page change
    history: 'push'
  }))

  return (
    <nav>
      <button onClick={() => setPage(p => p - 1)}>Previous</button>
      <span>Page {page}</span>
      <button onClick={() => setPage(p => p + 1)}>Next</button>
    </nav>
  )
}
```

**Override per-update:**

```tsx
// Usually no scroll
const [tab, setTab] = useQueryState('tab', parseAsString.withDefault('overview'))

// But scroll on tab change
setTab('details', { scroll: true })

// No scroll for internal update
setTab('overview', { scroll: false })
```

**Combine with history for full navigation UX:**

```tsx
const [page, setPage] = useQueryState('page', parseAsInteger.withDefault(1).withOptions({
  scroll: true,
  history: 'push',
  shallow: false
}))
// Back button restores position, forward navigates and scrolls
```

Reference: [nuqs Scroll Option](https://nuqs.dev/docs/options)
