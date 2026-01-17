---
title: Avoid Client-Side Data Fetching for Initial Data
impact: MEDIUM-HIGH
impactDescription: eliminates client waterfalls, better SEO
tags: server, data-fetching, seo, waterfalls
---

## Avoid Client-Side Data Fetching for Initial Data

Fetch initial page data in Server Components, not with `useEffect` or client-side libraries. Client-side fetching creates waterfalls and hurts SEO.

**Incorrect (client-side fetch with useEffect):**

```typescript
'use client'

import { useState, useEffect } from 'react'

export default function ProductsPage() {
  const [products, setProducts] = useState([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetch('/api/products')
      .then(res => res.json())
      .then(data => {
        setProducts(data)
        setLoading(false)
      })
  }, [])

  if (loading) return <Skeleton />
  return <ProductList products={products} />
}
// Waterfall: HTML → JS → Hydrate → Fetch → Render
// Empty for SEO crawlers
```

**Correct (Server Component fetch):**

```typescript
// app/products/page.tsx
export default async function ProductsPage() {
  const products = await fetch('https://api.store.com/products')
    .then(res => res.json())

  return <ProductList products={products} />
}
// Single request, data included in HTML, SEO-friendly
```

**When to use client-side fetching:**
- User-initiated actions (load more, search)
- Real-time updates (polling, WebSocket)
- After-interaction data (comments on expand)

**Recommended client-side library:**

```typescript
'use client'

import useSWR from 'swr'

export function SearchResults({ query }: { query: string }) {
  const { data, isLoading } = useSWR(
    query ? `/api/search?q=${query}` : null,
    fetcher
  )
  // Client fetch appropriate for user-initiated search
}
```
