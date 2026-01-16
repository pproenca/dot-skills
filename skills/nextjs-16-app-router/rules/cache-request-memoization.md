---
title: Use React cache() for Request-Scoped Deduplication
impact: HIGH
impactDescription: eliminates duplicate database calls within a single request, reduces queries from N to 1 per render tree
tags: cache, react-cache, memoization, deduplication, database
---

## Use React cache() for Request-Scoped Deduplication

When multiple Server Components in the same render tree need the same data, each component triggers a separate database query. React's `cache()` function deduplicates these calls within a single request, ensuring the expensive operation runs only once.

**Incorrect (duplicate queries in same request):**

```typescript
// app/lib/user.ts
import { db } from '@/lib/db'

export async function getCurrentUser() {
  // Called 5 times across components = 5 database queries
  const user = await db.user.findUnique({
    where: { id: getCurrentUserId() },
    include: { preferences: true },
  })
  return user
}

// app/components/Header.tsx - calls getCurrentUser()
// app/components/Sidebar.tsx - calls getCurrentUser()
// app/components/UserAvatar.tsx - calls getCurrentUser()
// app/products/page.tsx - calls getCurrentUser()
// app/components/CartIcon.tsx - calls getCurrentUser()
```

**Correct (deduplicated with React cache):**

```typescript
// app/lib/user.ts
import { cache } from 'react'
import { db } from '@/lib/db'

export const getCurrentUser = cache(async () => {
  // Called 5 times across components = 1 database query
  const user = await db.user.findUnique({
    where: { id: getCurrentUserId() },
    include: { preferences: true },
  })
  return user
})

// All components call getCurrentUser() freely
// React deduplicates within the same request
```

**With parameters:**

```typescript
// app/lib/products.ts
import { cache } from 'react'
import { db } from '@/lib/db'

// Memoized per unique productId within the same request
export const getProductById = cache(async (productId: string) => {
  const product = await db.product.findUnique({
    where: { id: productId },
    include: { category: true, images: true },
  })
  return product
})

// app/products/[id]/page.tsx
const product = await getProductById(params.id) // Query 1

// app/products/[id]/components/ProductDetails.tsx
const product = await getProductById(params.id) // Deduplicated - no query

// app/products/[id]/components/RelatedProducts.tsx
const product = await getProductById(params.id) // Deduplicated - no query
```

**Combine with unstable_cache for cross-request caching:**

```typescript
// app/lib/products.ts
import { cache } from 'react'
import { unstable_cache } from 'next/cache'
import { db } from '@/lib/db'

// Inner: Cross-request cache (persists between requests)
const getCachedProduct = unstable_cache(
  async (productId: string) => {
    return db.product.findUnique({ where: { id: productId } })
  },
  ['product'],
  { tags: ['products'], revalidate: 3600 }
)

// Outer: Request-scoped deduplication (within single render)
export const getProductById = cache(async (productId: string) => {
  return getCachedProduct(productId)
})
```

**When to use each caching layer:**

| Layer | Scope | Purpose |
|-------|-------|---------|
| `cache()` | Single request | Deduplicate calls across component tree |
| `unstable_cache` | Cross-request | Persist data between different requests |
| `fetch` cache | Cross-request | Cache HTTP responses |

**Note:** `fetch` GET requests are automatically deduplicated within a request. Use `cache()` for database queries, ORM calls, and other non-fetch data sources.

Reference: [React cache](https://react.dev/reference/react/cache) | [Next.js Request Memoization](https://nextjs.org/docs/app/building-your-application/caching#request-memoization)
