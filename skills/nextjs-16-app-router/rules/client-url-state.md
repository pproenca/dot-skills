---
title: Use URL State for Shareable Application State
impact: MEDIUM
impactDescription: enables shareable links, browser history, and server-side rendering of filtered views
tags: client, url-state, searchParams, useSearchParams, navigation
---

## Use URL State for Shareable Application State

Filter states, pagination, and view modes stored in useState are lost on page refresh and cannot be shared via URL. Using URL search params makes state bookmarkable, shareable, and enables server-side rendering of the filtered view.

**Incorrect (state lost on refresh):**

```tsx
'use client'

import { useState } from 'react'

export function ProductFilters({ products }: { products: Product[] }) {
  const [category, setCategory] = useState<string>('all')
  const [sortBy, setSortBy] = useState<string>('price')
  const [page, setPage] = useState(1)
  // State lost on refresh, users can't share filtered results

  const filteredProducts = filterProducts(products, { category, sortBy, page })

  return (
    <div>
      <select value={category} onChange={(e) => setCategory(e.target.value)}>
        <option value="all">All Categories</option>
        <option value="electronics">Electronics</option>
      </select>
      <ProductGrid products={filteredProducts} />
      <Pagination current={page} onChange={setPage} />
    </div>
  )
}
```

**Correct (state persisted in URL):**

```tsx
'use client'

import { useSearchParams, useRouter, usePathname } from 'next/navigation'
import { useCallback } from 'react'

export function ProductFilters({ products }: { products: Product[] }) {
  const searchParams = useSearchParams()
  const router = useRouter()
  const pathname = usePathname()

  const category = searchParams.get('category') ?? 'all'
  const sortBy = searchParams.get('sort') ?? 'price'
  const page = Number(searchParams.get('page') ?? 1)

  const updateParams = useCallback((updates: Record<string, string>) => {
    const params = new URLSearchParams(searchParams.toString())
    Object.entries(updates).forEach(([key, value]) => {
      params.set(key, value)
    })
    router.push(`${pathname}?${params.toString()}`)
  }, [searchParams, router, pathname])

  const filteredProducts = filterProducts(products, { category, sortBy, page })

  return (
    <div>
      <select
        value={category}
        onChange={(e) => updateParams({ category: e.target.value, page: '1' })}
      >
        <option value="all">All Categories</option>
        <option value="electronics">Electronics</option>
      </select>
      <ProductGrid products={filteredProducts} />
      <Pagination
        current={page}
        onChange={(p) => updateParams({ page: String(p) })}
      />
    </div>
  )
}
```

**Benefits:**
- Users can bookmark and share filtered views
- Browser back/forward navigation works naturally
- Server components can read searchParams for SSR
- Analytics can track filter usage from URLs

**When NOT to use:** For ephemeral UI state like modal open/close, dropdown expansion, or form input before submission, useState is more appropriate.

Reference: [Next.js useSearchParams](https://nextjs.org/docs/app/api-reference/functions/use-search-params)
