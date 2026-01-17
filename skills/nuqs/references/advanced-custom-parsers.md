---
title: Create Custom Parsers for Complex Types
impact: LOW
impactDescription: prevents runtime errors from string coercion
tags: advanced, createParser, custom, serialize, parse
---

## Create Custom Parsers for Complex Types

When built-in parsers don't fit your needs, create custom parsers with `createParser`. Define `parse`, `serialize`, and optionally `eq` for equality checking.

**Incorrect (manual parsing in component):**

```tsx
'use client'
import { useQueryState } from 'nuqs'

interface SortState {
  id: string
  desc: boolean
}

export default function SortableTable() {
  const [sortRaw, setSortRaw] = useQueryState('sort')
  // Manual parsing scattered across component
  const sort: SortState = sortRaw
    ? { id: sortRaw.split(':')[0], desc: sortRaw.split(':')[1] === 'desc' }
    : { id: 'name', desc: false }

  const handleSort = (id: string) => {
    // Manual serialization
    setSortRaw(`${id}:${sort.id === id && !sort.desc ? 'desc' : 'asc'}`)
  }
}
```

**Correct (custom parser):**

```tsx
'use client'
import { useQueryState, createParser } from 'nuqs'

interface SortState {
  id: string
  desc: boolean
}

const parseAsSort = createParser<SortState>({
  parse(query) {
    const [id = '', direction = ''] = query.split(':')
    return { id, desc: direction === 'desc' }
  },
  serialize(value) {
    return `${value.id}:${value.desc ? 'desc' : 'asc'}`
  },
  eq(a, b) {
    return a.id === b.id && a.desc === b.desc
  }
})

export default function SortableTable() {
  const [sort, setSort] = useQueryState(
    'sort',
    parseAsSort.withDefault({ id: 'name', desc: false })
  )
  // Type-safe, reusable, with proper equality checking
}
```

Reference: [nuqs Custom Parsers](https://nuqs.dev/docs/parsers/making-your-own)
