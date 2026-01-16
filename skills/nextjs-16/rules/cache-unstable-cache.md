---
title: Use unstable_cache for Non-Fetch Data Sources
impact: MEDIUM
impactDescription: Caches database queries and computations like fetch caching; avoids redundant database hits
tags: cache, unstable_cache, database, memoization
---

## Use unstable_cache for Non-Fetch Data Sources

While `fetch` has built-in caching, database queries and other data sources don't. Use `unstable_cache` (or the newer `'use cache'` directive) to cache results from ORMs, direct database queries, and computed values.

**Incorrect (no caching for DB queries):**

```typescript
// ❌ Hits database on every request
export default async function ProductPage({
  params,
}: {
  params: Promise<{ id: string }>
}) {
  const { id } = await params

  // Direct DB query - not cached
  const product = await db.product.findUnique({ where: { id } })
  const reviews = await db.review.findMany({ where: { productId: id } })

  return <Product product={product} reviews={reviews} />
}
```

**Correct (cached with unstable_cache):**

```typescript
import { unstable_cache } from 'next/cache'

const getProduct = unstable_cache(
  async (id: string) => {
    return db.product.findUnique({ where: { id } })
  },
  ['product'],  // Cache key prefix
  {
    tags: ['products'],  // For on-demand revalidation
    revalidate: 3600,    // 1 hour
  }
)

const getReviews = unstable_cache(
  async (productId: string) => {
    return db.review.findMany({ where: { productId } })
  },
  ['reviews'],
  {
    tags: ['reviews'],
    revalidate: 300,  // 5 minutes
  }
)

export default async function ProductPage({
  params,
}: {
  params: Promise<{ id: string }>
}) {
  const { id } = await params

  const [product, reviews] = await Promise.all([
    getProduct(id),
    getReviews(id),
  ])

  return <Product product={product} reviews={reviews} />
}
```

**Modern approach with 'use cache' (Next.js 15+):**

```typescript
import { cacheLife, cacheTag } from 'next/cache'

async function getProduct(id: string) {
  'use cache'
  cacheLife('hours')
  cacheTag('products', `product-${id}`)

  return db.product.findUnique({ where: { id } })
}

async function getReviews(productId: string) {
  'use cache'
  cacheLife('minutes')
  cacheTag('reviews', `reviews-${productId}`)

  return db.review.findMany({ where: { productId } })
}
```

**Cache key considerations:**

```typescript
// ❌ Same cache key for different queries
const getData = unstable_cache(
  async (type: string, id: string) => {
    if (type === 'product') return getProduct(id)
    if (type === 'user') return getUser(id)
  },
  ['data']  // Collision risk!
)

// ✓ Unique cache keys per data type
const getProduct = unstable_cache(fn, ['product'])
const getUser = unstable_cache(fn, ['user'])
```

**Revalidating cached data:**

```typescript
// actions/product.ts
'use server'

import { revalidateTag } from 'next/cache'

export async function updateProduct(id: string, data: ProductData) {
  await db.product.update({ where: { id }, data })
  revalidateTag(`product-${id}`)
  revalidateTag('products')  // Invalidate list caches too
}
```

**When NOT to use unstable_cache:**
- Data must be fresh every request
- User-specific data (no shared cache benefit)
- Mutations (use Server Actions)

Reference: [Next.js unstable_cache](https://nextjs.org/docs/app/api-reference/functions/unstable_cache)
