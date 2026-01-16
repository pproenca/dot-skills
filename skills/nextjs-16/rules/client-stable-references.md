---
title: Maintain Stable References with useCallback and useMemo
impact: HIGH
impactDescription: Prevents unnecessary re-renders in child components; eliminating unstable references reduces render cycles by 40-60% in complex UIs
tags: client, useCallback, useMemo, memoization, re-renders
---

## Maintain Stable References with useCallback and useMemo

Functions and objects created during render have new references each time. When passed as props to memoized children or used in dependency arrays, this triggers unnecessary re-renders. Use `useCallback` for functions and `useMemo` for objects.

**Incorrect (unstable references):**

```typescript
'use client'

import { useState } from 'react'

export default function ProductPage({ products }: { products: Product[] }) {
  const [sortOrder, setSortOrder] = useState<'asc' | 'desc'>('asc')

  // ❌ New function reference every render
  const handleSort = (order: 'asc' | 'desc') => {
    setSortOrder(order)
  }

  // ❌ New object reference every render
  const sortConfig = { order: sortOrder, field: 'price' }

  // ❌ New array reference every render
  const sorted = products.sort((a, b) =>
    sortOrder === 'asc' ? a.price - b.price : b.price - a.price
  )

  return (
    <div>
      {/* SortControls re-renders on every parent render */}
      <SortControls config={sortConfig} onSort={handleSort} />
      {/* ProductList re-renders on every parent render */}
      <ProductList products={sorted} />
    </div>
  )
}

const SortControls = memo(({ config, onSort }) => { /* ... */ })
const ProductList = memo(({ products }) => { /* ... */ })
```

**Correct (stable references):**

```typescript
'use client'

import { useState, useCallback, useMemo, memo } from 'react'

export default function ProductPage({ products }: { products: Product[] }) {
  const [sortOrder, setSortOrder] = useState<'asc' | 'desc'>('asc')

  // ✓ Stable function reference
  const handleSort = useCallback((order: 'asc' | 'desc') => {
    setSortOrder(order)
  }, [])

  // ✓ Stable object reference (only changes when sortOrder changes)
  const sortConfig = useMemo(
    () => ({ order: sortOrder, field: 'price' }),
    [sortOrder]
  )

  // ✓ Stable array reference (only recalculates when dependencies change)
  const sorted = useMemo(
    () => [...products].sort((a, b) =>
      sortOrder === 'asc' ? a.price - b.price : b.price - a.price
    ),
    [products, sortOrder]
  )

  return (
    <div>
      {/* SortControls only re-renders when sortConfig changes */}
      <SortControls config={sortConfig} onSort={handleSort} />
      {/* ProductList only re-renders when sorted changes */}
      <ProductList products={sorted} />
    </div>
  )
}

const SortControls = memo(({ config, onSort }) => { /* ... */ })
const ProductList = memo(({ products }) => { /* ... */ })
```

**React Compiler note:**
The React Compiler (experimental) automatically adds memoization. If using Next.js with React Compiler enabled, manual useCallback/useMemo may be unnecessary.

**When NOT to memoize:**
- Component doesn't have expensive children
- Props are already stable (primitives, refs)
- Premature optimization (profile first)

Reference: [React useMemo](https://react.dev/reference/react/useMemo)
