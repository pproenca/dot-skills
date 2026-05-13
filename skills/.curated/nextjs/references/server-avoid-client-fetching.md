---
title: Initial page data lands in the HTML via a Server Component — never via `useEffect`+`fetch` or client-side data libraries
impact: MEDIUM-HIGH
impactDescription: eliminates the HTML → JS → hydrate → fetch → render waterfall; ships initial data in the SSR output; SEO works without crawler-specific tricks
tags: server, no-client-fetch, ssr-initial-data, anti-useEffect-fetch
---

## Initial page data lands in the HTML via a Server Component — never via `useEffect`+`fetch` or client-side data libraries

**Pattern intent:** data that the page needs in order to render must arrive with the SSR HTML. Fetching it on the client after hydration produces an empty initial render, a skeleton flash, and SEO crawlers that see nothing.

### Shapes to recognize

- A `'use client'` page with `useState` + `useEffect` + `fetch('/api/...')` + a loading skeleton — the canonical anti-pattern.
- A TanStack Query / SWR `useQuery('/api/foo')` in a Client Component for data that doesn't change after first render — should be a Server Component fetch.
- A `useSWR` for the *current user* — that data is per-request and known on the server; ship it in the SSR.
- A page that's `'use client'` "because that's how we always do it" — the team's Next.js 12 muscle memory; rewrite as Server Component.
- A "data hook" (`useUser`, `useDashboardData`) that wraps a client fetch and is called from every page — needs to be a server function or a `cache()`-wrapped fetcher.
- Workaround: server-render an empty shell + hydrate with client data — works but throws away the SSR benefit.

The canonical resolution: convert the page to a Server Component (`async function`, no `'use client'`); `await` the data directly. For interactivity inside, push `'use client'` down to a small leaf via composition. Use SWR/TanStack Query only for *user-initiated* refetches (search-as-you-type, infinite scroll, polling, optimistic mutations).

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

---

### In disguise — TanStack Query / SWR fetching *initial* page data instead of user-driven refetches

The grep-friendly anti-pattern is `useEffect` + `fetch`. The disguise is the same waterfall hidden behind a *legitimate* library — TanStack Query or SWR — used in a Client Component for data that the page needs to render at all. The library is a great fit for user-driven refetches; it's the wrong tool when the data is needed for the initial paint.

**Incorrect — in disguise (TanStack Query for initial page data):**

```typescript
// app/dashboard/page.tsx
'use client'

import { useQuery } from '@tanstack/react-query'

export default function DashboardPage() {
  // Initial dashboard data — same per-user, fetched fresh on mount
  const { data, isLoading } = useQuery({
    queryKey: ['dashboard'],
    queryFn: () => fetch('/api/dashboard').then((r) => r.json()),
  })

  if (isLoading) return <DashboardSkeleton />
  return <Dashboard data={data} />
}
```

What this looks like in production:
1. Browser fetches `/dashboard` → server returns HTML shell with no data.
2. Browser downloads the JS bundle (which now includes TanStack Query, the fetcher, the Dashboard component).
3. Hydration runs; `useQuery` fires `/api/dashboard`.
4. Skeleton shows for 200-500ms.
5. Dashboard appears.

The fact that it's TanStack Query rather than `useEffect` doesn't change the waterfall — and the SEO crawler still sees the skeleton HTML.

**Correct — Server Component for initial data, client library for user-driven refetches:**

```typescript
// app/dashboard/page.tsx (Server Component)
import { Suspense } from 'react'
import { getDashboardData } from '@/lib/dashboard'
import { DashboardActions } from './DashboardActions'

export default async function DashboardPage() {
  const data = await getDashboardData() // server-side, ships in initial HTML
  return (
    <>
      <Dashboard data={data} />
      <DashboardActions /> {/* client island for refresh / actions */}
    </>
  )
}

// app/dashboard/DashboardActions.tsx — TanStack Query stays for what it's good at
'use client'
import { useMutation, useQueryClient } from '@tanstack/react-query'

export function DashboardActions() {
  const qc = useQueryClient()
  const refresh = useMutation({
    mutationFn: () => fetch('/api/dashboard', { method: 'POST' }),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['dashboard'] }),
  })
  return <button onClick={() => refresh.mutate()}>Refresh</button>
}
```

Server fetch ships data inline; TanStack Query stays available for *user-initiated* mutations and refetches.
