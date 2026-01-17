---
title: Use the 'use cache' Directive for Explicit Caching
impact: CRITICAL
impactDescription: eliminates implicit caching confusion, explicit control
tags: cache, use-cache, directive, data-fetching
---

## Use the 'use cache' Directive for Explicit Caching

Next.js 16 introduces Cache Components with the `'use cache'` directive. Unlike implicit caching in previous versions, caching is now opt-in and explicit.

**Incorrect (relying on implicit caching):**

```typescript
// app/products/page.tsx
export default async function ProductsPage() {
  // In Next.js 15, this was cached by default
  // In Next.js 16, this fetches fresh data every request
  const products = await fetch('https://api.store.com/products')

  return <ProductList products={products} />
}
```

**Correct (explicit caching with 'use cache'):**

```typescript
// app/products/page.tsx
'use cache'

export default async function ProductsPage() {
  const products = await fetch('https://api.store.com/products')

  return <ProductList products={products} />
}
// Entire page is cached until manually invalidated
```

**Alternative (cache specific functions):**

```typescript
// lib/data.ts
import { unstable_cache } from 'next/cache'

export const getProducts = unstable_cache(
  async () => {
    const res = await fetch('https://api.store.com/products')
    return res.json()
  },
  ['products'],
  { revalidate: 3600 }  // Cache for 1 hour
)
```

Reference: [Next.js 16 Cache Components](https://nextjs.org/blog/next-16)
