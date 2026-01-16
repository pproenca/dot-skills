---
title: Use 'use cache' for Expensive Computations
impact: CRITICAL
impactDescription: Caches function results at the edge; eliminates repeated computation, serves cached results in <50ms vs 200-2000ms uncached
tags: async, use-cache, caching, cacheLife
---

## Use 'use cache' for Expensive Computations

The `'use cache'` directive marks async functions for caching. Combined with `cacheLife`, it enables fine-grained control over cache duration. This is particularly powerful for database queries and API calls that don't change frequently.

**Incorrect (no caching, repeated work):**

```typescript
export default async function ProductPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params

  // These run on EVERY request
  const product = await db.query('SELECT * FROM products WHERE id = ?', [id])
  const reviews = await db.query('SELECT * FROM reviews WHERE product_id = ?', [id])
  const related = await computeRelatedProducts(id) // Expensive ML computation

  return <ProductDisplay product={product} reviews={reviews} related={related} />
}
```

**Correct (cached with 'use cache'):**

```typescript
import { cacheLife, cacheTag } from 'next/cache'

async function getProduct(id: string) {
  'use cache'
  cacheLife('hours') // Cache for 1 hour
  cacheTag('products', `product-${id}`)

  return db.query('SELECT * FROM products WHERE id = ?', [id])
}

async function getReviews(productId: string) {
  'use cache'
  cacheLife('minutes') // Reviews change more often
  cacheTag('reviews', `reviews-${productId}`)

  return db.query('SELECT * FROM reviews WHERE product_id = ?', [productId])
}

async function getRelatedProducts(id: string) {
  'use cache'
  cacheLife('days') // ML results stable for days
  cacheTag('related', `related-${id}`)

  return computeRelatedProducts(id)
}

export default async function ProductPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params

  const [product, reviews, related] = await Promise.all([
    getProduct(id),
    getReviews(id),
    getRelatedProducts(id),
  ])

  return <ProductDisplay product={product} reviews={reviews} related={related} />
}
```

**Custom cache configuration:**

```typescript
async function getUserData(userId: string) {
  'use cache'
  cacheLife({
    stale: 60,       // Serve stale for 1 minute
    revalidate: 300, // Revalidate after 5 minutes
    expire: 3600,    // Hard expire after 1 hour
  })
  cacheTag('user', `user-${userId}`)

  return fetchUserFromDatabase(userId)
}
```

**When NOT to use this pattern:**
- Data must be fresh on every request (use `cache: 'no-store'`)
- Data depends on request-specific context like cookies (use dynamic rendering)

Reference: [Next.js Caching](https://nextjs.org/docs/app/building-your-application/caching)
