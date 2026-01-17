---
title: Create Custom Parsers for Complex Types
impact: LOW
impactDescription: enables type-safe URL state for domain-specific types
tags: advanced, createParser, custom, serialize, parse
---

## Create Custom Parsers for Complex Types

When built-in parsers don't fit your needs, create custom parsers with `createParser`. Define `parse`, `serialize`, and optionally `eq` for equality checking.

**Custom parser structure:**

```tsx
import { createParser } from 'nuqs'

const myParser = createParser({
  parse: (value: string) => /* convert string to your type */,
  serialize: (value: MyType) => /* convert your type to string */,
  eq: (a: MyType, b: MyType) => /* optional: compare for equality */
})
```

**Example: TanStack Table sorting state**

```tsx
import { createParser, parseAsStringLiteral } from 'nuqs'

interface SortState {
  id: string
  desc: boolean
}

export const parseAsSort = createParser<SortState>({
  parse(query) {
    const [id = '', direction = ''] = query.split(':')
    const desc = direction === 'desc'
    return { id, desc }
  },
  serialize(value) {
    return `${value.id}:${value.desc ? 'desc' : 'asc'}`
  },
  eq(a, b) {
    return a.id === b.id && a.desc === b.desc
  }
})

// Usage
const [sort, setSort] = useQueryState('sort', parseAsSort.withDefault({ id: 'name', desc: false }))
// URL: ?sort=name:asc
```

**Example: Coordinate pair**

```tsx
import { createParser } from 'nuqs'

interface Coordinates {
  lat: number
  lng: number
}

export const parseAsCoordinates = createParser<Coordinates>({
  parse(query) {
    const [lat, lng] = query.split(',').map(Number)
    if (isNaN(lat) || isNaN(lng)) return null
    return { lat, lng }
  },
  serialize({ lat, lng }) {
    return `${lat},${lng}`
  }
})

// Usage
const [coords, setCoords] = useQueryState('coords', parseAsCoordinates)
// URL: ?coords=48.8566,2.3522
```

**Example: Enum with validation**

```tsx
import { createParser } from 'nuqs'

type Status = 'draft' | 'published' | 'archived'
const validStatuses: Status[] = ['draft', 'published', 'archived']

export const parseAsStatus = createParser<Status>({
  parse(query) {
    return validStatuses.includes(query as Status) ? (query as Status) : null
  },
  serialize(value) {
    return value
  }
})
```

Reference: [nuqs Custom Parsers](https://nuqs.dev/docs/parsers/making-your-own)
