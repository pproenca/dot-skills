---
title: Use useTransition for Non-Blocking Updates
impact: HIGH
impactDescription: Keeps UI responsive during expensive state updates; prevents 100-500ms freezes when filtering large lists or heavy computations
tags: client, useTransition, concurrent, responsiveness
---

## Use useTransition for Non-Blocking Updates

`useTransition` marks state updates as non-urgent, allowing React to keep the UI responsive. Use it when updates trigger expensive renders (filtering large lists, complex calculations) to prevent the interface from freezing.

**Incorrect (blocking updates):**

```typescript
'use client'

import { useState } from 'react'

export default function ProductSearch({ products }: { products: Product[] }) {
  const [query, setQuery] = useState('')

  // Filtering 10,000 products on each keystroke blocks the input
  const filtered = products.filter(p =>
    p.name.toLowerCase().includes(query.toLowerCase())
  )

  return (
    <div>
      {/* Input feels laggy because filter blocks each render */}
      <input
        value={query}
        onChange={e => setQuery(e.target.value)}
        placeholder="Search products..."
      />
      <ProductList products={filtered} />
    </div>
  )
}
```

**Correct (non-blocking with useTransition):**

```typescript
'use client'

import { useState, useTransition, useMemo } from 'react'

export default function ProductSearch({ products }: { products: Product[] }) {
  const [query, setQuery] = useState('')
  const [deferredQuery, setDeferredQuery] = useState('')
  const [isPending, startTransition] = useTransition()

  // Expensive filter uses deferred value
  const filtered = useMemo(
    () => products.filter(p =>
      p.name.toLowerCase().includes(deferredQuery.toLowerCase())
    ),
    [products, deferredQuery]
  )

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value
    setQuery(value)  // Urgent: update input immediately

    startTransition(() => {
      setDeferredQuery(value)  // Non-urgent: can be interrupted
    })
  }

  return (
    <div>
      {/* Input stays responsive */}
      <input
        value={query}
        onChange={handleChange}
        placeholder="Search products..."
      />
      {isPending && <span>Filtering...</span>}
      <ProductList products={filtered} />
    </div>
  )
}
```

**Alternative with useDeferredValue:**

```typescript
'use client'

import { useState, useDeferredValue, useMemo } from 'react'

export default function ProductSearch({ products }: { products: Product[] }) {
  const [query, setQuery] = useState('')
  const deferredQuery = useDeferredValue(query)

  const filtered = useMemo(
    () => products.filter(p =>
      p.name.toLowerCase().includes(deferredQuery.toLowerCase())
    ),
    [products, deferredQuery]
  )

  const isStale = query !== deferredQuery

  return (
    <div>
      <input
        value={query}
        onChange={e => setQuery(e.target.value)}
        placeholder="Search products..."
      />
      <div style={{ opacity: isStale ? 0.7 : 1 }}>
        <ProductList products={filtered} />
      </div>
    </div>
  )
}
```

**When to use which:**
- `useTransition`: When you control the state update
- `useDeferredValue`: When you receive the value as a prop

**When NOT to use this pattern:**
- Updates are cheap and don't cause lag
- Immediate feedback is required (form validation)
- List has <100 items

Reference: [React useTransition](https://react.dev/reference/react/useTransition)
