---
title: Use withOptions for Parser-Level Configuration
impact: MEDIUM
impactDescription: reduces boilerplate and ensures consistent behavior
tags: state, withOptions, configuration, parsers, reusability
---

## Use withOptions for Parser-Level Configuration

Instead of passing options to every `useQueryState` call, configure options on the parser itself with `withOptions`. This ensures consistent behavior and reduces repetition.

**Incorrect (repeated options):**

```tsx
'use client'
import { useQueryState, parseAsString } from 'nuqs'

export default function SearchPage() {
  const [query, setQuery] = useQueryState('q', {
    ...parseAsString,
    shallow: false,
    throttleMs: 500,
    history: 'push'
  })

  const [filter, setFilter] = useQueryState('filter', {
    ...parseAsString,
    shallow: false,
    throttleMs: 500,
    history: 'push'
  })

  // Repeated configuration for each parameter
}
```

**Correct (parser-level options):**

```tsx
// lib/searchParams.ts
import { parseAsString, parseAsInteger } from 'nuqs'

const serverSyncOptions = {
  shallow: false,
  throttleMs: 500,
  history: 'push' as const
}

export const searchParams = {
  query: parseAsString.withDefault('').withOptions(serverSyncOptions),
  filter: parseAsString.withDefault('').withOptions(serverSyncOptions),
  page: parseAsInteger.withDefault(1).withOptions(serverSyncOptions)
}

// components/SearchPage.tsx
'use client'
import { useQueryState } from 'nuqs'
import { searchParams } from '@/lib/searchParams'

export default function SearchPage() {
  const [query, setQuery] = useQueryState('q', searchParams.query)
  const [filter, setFilter] = useQueryState('filter', searchParams.filter)
  const [page, setPage] = useQueryState('page', searchParams.page)

  // All use the same options consistently
}
```

**Options can be chained:**

```tsx
parseAsInteger
  .withDefault(1)
  .withOptions({ shallow: false })
  .withOptions({ throttleMs: 300 }) // Merges with previous options
```

Reference: [nuqs Options](https://nuqs.dev/docs/options)
