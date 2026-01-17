---
title: Share Parsers Between Client and Server
impact: HIGH
impactDescription: prevents client/server hydration mismatches
tags: server, parsers, shared, consistency, client-server
---

## Share Parsers Between Client and Server

Define parsers once and reuse them in both `createSearchParamsCache` (server) and `useQueryState` (client). This ensures consistent parsing behavior and prevents bugs from mismatched configurations.

**Incorrect (separate definitions):**

```tsx
// app/search/page.tsx (Server)
import { createSearchParamsCache, parseAsInteger } from 'nuqs/server'

const cache = createSearchParamsCache({
  page: parseAsInteger.withDefault(1)
})

// components/Pagination.tsx (Client)
'use client'
import { useQueryState, parseAsInteger } from 'nuqs'

export function Pagination() {
  // Different default - inconsistent!
  const [page, setPage] = useQueryState('page', parseAsInteger.withDefault(0))
}
```

**Correct (shared definition):**

```tsx
// lib/searchParams.ts
import { parseAsInteger, parseAsString } from 'nuqs' // Works for both

export const searchParamsParsers = {
  q: parseAsString.withDefault(''),
  page: parseAsInteger.withDefault(1),
  limit: parseAsInteger.withDefault(10)
}

// lib/searchParams.server.ts
import { createSearchParamsCache } from 'nuqs/server'
import { searchParamsParsers } from './searchParams'

export const searchParamsCache = createSearchParamsCache(searchParamsParsers)

// app/search/page.tsx (Server)
import { searchParamsCache } from '@/lib/searchParams.server'

export default async function SearchPage({ searchParams }) {
  const { q, page } = await searchParamsCache.parse(searchParams)
  return <Results query={q} page={page} />
}

// components/Pagination.tsx (Client)
'use client'
import { useQueryState } from 'nuqs'
import { searchParamsParsers } from '@/lib/searchParams'

export function Pagination() {
  const [page, setPage] = useQueryState('page', searchParamsParsers.page)
  // Uses same parser with same default as server
}
```

**Benefits:**
- Single source of truth for defaults
- TypeScript catches inconsistencies
- Easier to update configuration

Reference: [nuqs Documentation](https://nuqs.dev/docs)
