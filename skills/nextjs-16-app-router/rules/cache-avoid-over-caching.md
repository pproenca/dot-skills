---
title: Avoid Caching User-Specific or Frequently Changing Data
impact: HIGH
impactDescription: prevents serving stale/wrong data to users, eliminates cache poisoning and privacy leaks
tags: cache, security, user-data, dynamic-data, unstable_noStore
---

## Avoid Caching User-Specific or Frequently Changing Data

Caching user-specific data can leak private information between users or serve stale personalized content. Similarly, caching frequently changing data like inventory counts or live prices leads to poor user experience and potential business logic errors.

**Incorrect (caching user-specific data):**

```typescript
// app/lib/user.ts
import { unstable_cache } from 'next/cache'
import { db } from '@/lib/db'

// DANGEROUS: User A's cart could be served to User B
export const getUserCart = unstable_cache(
  async (userId: string) => {
    const cart = await db.cart.findUnique({
      where: { userId },
      include: { items: true },
    })
    return cart
  },
  ['user-cart'],
  { revalidate: 60 }
)

// DANGEROUS: Caching personalized recommendations
export const getUserRecommendations = unstable_cache(
  async (userId: string) => {
    return db.recommendation.findMany({ where: { userId } })
  },
  ['recommendations'],
  { revalidate: 300 }
)
```

**Correct (opt out of caching for user-specific data):**

```typescript
// app/lib/user.ts
import { unstable_noStore } from 'next/cache'
import { db } from '@/lib/db'

export async function getUserCart(userId: string) {
  unstable_noStore() // Explicitly opt out of caching
  const cart = await db.cart.findUnique({
    where: { userId },
    include: { items: true },
  })
  return cart
}

export async function getUserRecommendations(userId: string) {
  unstable_noStore()
  return db.recommendation.findMany({ where: { userId } })
}
```

**Data that should NOT be cached:**

```typescript
// app/lib/inventory.ts
import { unstable_noStore } from 'next/cache'

// Real-time inventory - stale data causes overselling
export async function getProductStock(productId: string) {
  unstable_noStore()
  const response = await fetch(`/api/inventory/${productId}`, {
    cache: 'no-store', // Also set on fetch for clarity
  })
  return response.json()
}

// Live pricing - must reflect current market conditions
export async function getCurrentPrice(productId: string) {
  unstable_noStore()
  return fetch(`/api/pricing/${productId}`, { cache: 'no-store' })
}

// Session-dependent data
export async function getUserSession() {
  unstable_noStore()
  return getServerSession(authOptions)
}
```

**Separate cacheable from non-cacheable data:**

```typescript
// app/products/[id]/page.tsx
import { unstable_cache } from 'next/cache'
import { unstable_noStore } from 'next/cache'

// CACHEABLE: Product details rarely change
const getProductDetails = unstable_cache(
  async (productId: string) => ({
    name: await db.product.findUnique({ where: { id: productId } }),
  }),
  ['product-details'],
  { tags: ['products'], revalidate: 3600 }
)

// NOT CACHEABLE: Stock changes constantly
async function getProductStock(productId: string) {
  unstable_noStore()
  return db.inventory.findUnique({ where: { productId } })
}

export default async function ProductPage({ params }: { params: { id: string } }) {
  // Parallel fetch: cached product + fresh stock
  const [product, stock] = await Promise.all([
    getProductDetails(params.id),
    getProductStock(params.id),
  ])

  return <ProductView product={product} stock={stock} />
}
```

**Categories of data by cacheability:**

| Cache Aggressively | Cache Briefly | Never Cache |
|--------------------|---------------|-------------|
| Product catalog | Search results | User sessions |
| Static content | Trending items | Shopping carts |
| Category lists | Public counters | Payment info |
| Feature flags | API rate limits | Real-time inventory |

Reference: [Next.js unstable_noStore](https://nextjs.org/docs/app/api-reference/functions/unstable_noStore) | [Opting out of caching](https://nextjs.org/docs/app/building-your-application/caching#opting-out)
