---
title: Use URL State for Shareable UI State
impact: HIGH
impactDescription: URL-based state is shareable, bookmarkable, and persists across refreshes; eliminates lost state and improves UX
tags: client, url-state, searchParams, navigation
---

## Use URL State for Shareable UI State

Store filter, sort, and view preferences in URL search parameters instead of component state. This makes UI state shareable via link, bookmarkable, and persistent across page refreshes.

**Incorrect (lost state on refresh):**

```typescript
'use client'

import { useState } from 'react'

export default function ProductList({ products }) {
  const [category, setCategory] = useState('all')
  const [sort, setSort] = useState('price-asc')
  const [page, setPage] = useState(1)

  // ❌ Refresh loses all state
  // ❌ Can't share filtered view
  // ❌ Back button doesn't restore state

  return (/* ... */)
}
```

**Correct (URL-based state):**

```typescript
'use client'

import { useSearchParams, useRouter, usePathname } from 'next/navigation'

export default function ProductList({ products }) {
  const searchParams = useSearchParams()
  const router = useRouter()
  const pathname = usePathname()

  // Read from URL
  const category = searchParams.get('category') ?? 'all'
  const sort = searchParams.get('sort') ?? 'price-asc'
  const page = parseInt(searchParams.get('page') ?? '1')

  // Update URL
  const updateParams = (updates: Record<string, string>) => {
    const params = new URLSearchParams(searchParams)
    Object.entries(updates).forEach(([key, value]) => {
      if (value) {
        params.set(key, value)
      } else {
        params.delete(key)
      }
    })
    router.push(`${pathname}?${params.toString()}`)
  }

  return (
    <div>
      <select
        value={category}
        onChange={e => updateParams({ category: e.target.value, page: '1' })}
      >
        <option value="all">All</option>
        <option value="electronics">Electronics</option>
      </select>

      <select
        value={sort}
        onChange={e => updateParams({ sort: e.target.value })}
      >
        <option value="price-asc">Price: Low to High</option>
        <option value="price-desc">Price: High to Low</option>
      </select>

      {/* URL: /products?category=electronics&sort=price-asc&page=2 */}
    </div>
  )
}
```

**Server Component reading URL state:**

```typescript
// app/products/page.tsx
export default async function ProductsPage({
  searchParams,
}: {
  searchParams: Promise<{ category?: string; sort?: string; page?: string }>
}) {
  const params = await searchParams
  const category = params.category ?? 'all'
  const sort = params.sort ?? 'price-asc'
  const page = parseInt(params.page ?? '1')

  const products = await getProducts({ category, sort, page })

  return <ProductList products={products} />
}
```

**Hook for URL state management:**

```typescript
// hooks/useQueryState.ts
'use client'

import { useSearchParams, useRouter, usePathname } from 'next/navigation'
import { useCallback } from 'react'

export function useQueryState(key: string, defaultValue: string) {
  const searchParams = useSearchParams()
  const router = useRouter()
  const pathname = usePathname()

  const value = searchParams.get(key) ?? defaultValue

  const setValue = useCallback((newValue: string) => {
    const params = new URLSearchParams(searchParams)
    if (newValue === defaultValue) {
      params.delete(key)
    } else {
      params.set(key, newValue)
    }
    router.push(`${pathname}?${params.toString()}`)
  }, [searchParams, router, pathname, key, defaultValue])

  return [value, setValue] as const
}
```

**When NOT to use URL state:**
- Sensitive data (passwords, tokens)
- High-frequency updates (typing in search as you type)
- Temporary UI state (open/closed modals)

Reference: [Next.js useSearchParams](https://nextjs.org/docs/app/api-reference/functions/use-search-params)
