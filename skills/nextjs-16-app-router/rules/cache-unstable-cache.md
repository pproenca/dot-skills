---
title: Use unstable_cache for Non-Fetch Data Sources
impact: HIGH
impactDescription: reduces database queries by 80-95% for repeated reads, cuts response time from 200ms to 5ms
tags: cache, unstable_cache, database, orm, prisma
---

## Use unstable_cache for Non-Fetch Data Sources

The `fetch` cache only works with HTTP requests. Database queries, ORM calls, and other data sources bypass Next.js caching entirely unless wrapped with `unstable_cache`. Without it, every page render triggers a fresh database query.

**Incorrect (uncached database queries):**

```typescript
// app/lib/products.ts
import { db } from '@/lib/db'

export async function getProducts() {
  // Hits database on EVERY request - no caching
  const products = await db.product.findMany({
    where: { status: 'active' },
    orderBy: { createdAt: 'desc' },
  })
  return products
}

export async function getProductById(productId: string) {
  // Another uncached query - multiplies DB load under traffic
  const product = await db.product.findUnique({
    where: { id: productId },
  })
  return product
}
```

**Correct (cached with unstable_cache):**

```typescript
// app/lib/products.ts
import { unstable_cache } from 'next/cache'
import { db } from '@/lib/db'

export const getProducts = unstable_cache(
  async () => {
    const products = await db.product.findMany({
      where: { status: 'active' },
      orderBy: { createdAt: 'desc' },
    })
    return products
  },
  ['products-list'],
  { tags: ['products'], revalidate: 3600 }
)

export const getProductById = unstable_cache(
  async (productId: string) => {
    const product = await db.product.findUnique({
      where: { id: productId },
    })
    return product
  },
  ['product-detail'],
  { tags: ['products'], revalidate: 3600 }
)
```

**With dynamic cache keys:**

```typescript
// app/lib/products.ts
import { unstable_cache } from 'next/cache'
import { db } from '@/lib/db'

// Cache key includes the productId for separate cache entries
export const getProductById = (productId: string) =>
  unstable_cache(
    async () => {
      const product = await db.product.findUnique({
        where: { id: productId },
        include: { category: true, reviews: true },
      })
      return product
    },
    [`product-${productId}`],
    { tags: [`product-${productId}`, 'products'], revalidate: 3600 }
  )()

// Usage in Server Component
const product = await getProductById('prod_123')
```

**When NOT to use:**

- User-specific data (use `unstable_noStore` instead)
- Real-time data requiring sub-second freshness
- Data with complex invalidation requirements

```typescript
import { unstable_noStore } from 'next/cache'

export async function getUserCart(userId: string) {
  unstable_noStore() // Opt out of caching for user-specific data
  return db.cart.findUnique({ where: { userId } })
}
```

Reference: [Next.js unstable_cache](https://nextjs.org/docs/app/api-reference/functions/unstable_cache)
