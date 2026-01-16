---
title: Minimize Client-Side State
impact: HIGH
impactDescription: Each useState triggers re-renders; eliminating unnecessary state reduces render cycles by 30-50% in typical components
tags: client, state, useState, performance
---

## Minimize Client-Side State

Every useState hook is a potential re-render trigger. Derive values from props or existing state instead of storing redundant data. Move data fetching to Server Components where possible.

**Incorrect (redundant state):**

```typescript
'use client'

import { useState, useEffect } from 'react'

export default function ProductFilter({ products }: { products: Product[] }) {
  const [allProducts] = useState(products)  // Redundant - use props
  const [filteredProducts, setFilteredProducts] = useState(products)  // Derived state
  const [category, setCategory] = useState('all')
  const [totalCount, setTotalCount] = useState(products.length)  // Derived

  useEffect(() => {
    const filtered = category === 'all'
      ? allProducts
      : allProducts.filter(p => p.category === category)
    setFilteredProducts(filtered)
    setTotalCount(filtered.length)
  }, [category, allProducts])

  return (
    <div>
      <p>{totalCount} products</p>
      <select value={category} onChange={e => setCategory(e.target.value)}>
        <option value="all">All</option>
        <option value="electronics">Electronics</option>
      </select>
      <ProductList products={filteredProducts} />
    </div>
  )
}
```

**Correct (minimal state, derived values):**

```typescript
'use client'

import { useState, useMemo } from 'react'

export default function ProductFilter({ products }: { products: Product[] }) {
  // Only store what user controls
  const [category, setCategory] = useState('all')

  // Derive everything else
  const filteredProducts = useMemo(
    () => category === 'all'
      ? products
      : products.filter(p => p.category === category),
    [products, category]
  )

  // No state needed - just a calculation
  const totalCount = filteredProducts.length

  return (
    <div>
      <p>{totalCount} products</p>
      <select value={category} onChange={e => setCategory(e.target.value)}>
        <option value="all">All</option>
        <option value="electronics">Electronics</option>
      </select>
      <ProductList products={filteredProducts} />
    </div>
  )
}
```

**Even better - move to URL state:**

```typescript
'use client'

import { useSearchParams, useRouter } from 'next/navigation'
import { useMemo } from 'react'

export default function ProductFilter({ products }: { products: Product[] }) {
  const searchParams = useSearchParams()
  const router = useRouter()

  // State in URL - shareable, bookmarkable
  const category = searchParams.get('category') ?? 'all'

  const filteredProducts = useMemo(
    () => category === 'all'
      ? products
      : products.filter(p => p.category === category),
    [products, category]
  )

  const setCategory = (value: string) => {
    const params = new URLSearchParams(searchParams)
    params.set('category', value)
    router.push(`?${params.toString()}`)
  }

  return (/* same JSX */)
}
```

**Rules of thumb:**
- If it can be derived, don't store it
- If it can live in URL, use searchParams
- If it can be fetched server-side, use Server Components

**When NOT to use this pattern:**
- Complex form state requiring immediate feedback
- Optimistic UI updates that need local state

Reference: [React useState](https://react.dev/reference/react/useState#avoiding-recreating-the-initial-state)
