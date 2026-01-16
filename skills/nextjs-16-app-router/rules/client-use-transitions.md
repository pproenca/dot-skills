---
title: Use useTransition for Non-Blocking Updates
impact: MEDIUM
impactDescription: maintains 60fps input responsiveness during heavy renders
tags: client, useTransition, concurrent, performance, responsiveness
---

## Use useTransition for Non-Blocking Updates

Expensive state updates like filtering large lists can freeze the UI, making inputs feel unresponsive. useTransition marks updates as non-urgent, allowing React to interrupt rendering to handle user input and keep the interface responsive.

**Incorrect (UI freezes during filter):**

```tsx
'use client'

import { useState } from 'react'

export function SearchableProductList({ products }: { products: Product[] }) {
  const [query, setQuery] = useState('')
  const [filteredProducts, setFilteredProducts] = useState(products)

  const handleSearch = (value: string) => {
    setQuery(value)
    // Expensive filter blocks input, UI feels laggy
    const filtered = products.filter((p) =>
      p.name.toLowerCase().includes(value.toLowerCase()) ||
      p.description.toLowerCase().includes(value.toLowerCase())
    )
    setFilteredProducts(filtered)
  }

  return (
    <div>
      <input
        value={query}
        onChange={(e) => handleSearch(e.target.value)}
        placeholder="Search products..."
      />
      <ProductGrid products={filteredProducts} />
    </div>
  )
}
```

**Correct (non-blocking with useTransition):**

```tsx
'use client'

import { useState, useTransition } from 'react'

export function SearchableProductList({ products }: { products: Product[] }) {
  const [query, setQuery] = useState('')
  const [filteredProducts, setFilteredProducts] = useState(products)
  const [isPending, startTransition] = useTransition()

  const handleSearch = (value: string) => {
    setQuery(value)  // Urgent: update input immediately
    startTransition(() => {
      // Non-urgent: can be interrupted if user types again
      const filtered = products.filter((p) =>
        p.name.toLowerCase().includes(value.toLowerCase()) ||
        p.description.toLowerCase().includes(value.toLowerCase())
      )
      setFilteredProducts(filtered)
    })
  }

  return (
    <div>
      <input
        value={query}
        onChange={(e) => handleSearch(e.target.value)}
        placeholder="Search products..."
      />
      {isPending && <LoadingSpinner />}
      <ProductGrid products={filteredProducts} />
    </div>
  )
}
```

**With router navigation:**

```tsx
'use client'

import { useTransition } from 'react'
import { useRouter } from 'next/navigation'

export function TabNavigation({ tabs }: { tabs: Tab[] }) {
  const [isPending, startTransition] = useTransition()
  const router = useRouter()

  const handleTabChange = (tabId: string) => {
    startTransition(() => {
      router.push(`/dashboard/${tabId}`)
    })
  }

  return (
    <nav className={isPending ? 'opacity-70' : ''}>
      {tabs.map((tab) => (
        <button key={tab.id} onClick={() => handleTabChange(tab.id)}>
          {tab.label}
        </button>
      ))}
    </nav>
  )
}
```

**When NOT to use:** For quick, simple state updates that render instantly, the overhead of useTransition adds unnecessary complexity.

Reference: [React useTransition](https://react.dev/reference/react/useTransition)
