---
title: Use fetch Cache Options Appropriately
impact: HIGH
impactDescription: eliminates redundant API calls, reduces server load by 60-90% for cacheable data
tags: cache, fetch, force-cache, no-store, revalidate
---

## Use fetch Cache Options Appropriately

Next.js extends the native `fetch` API with caching options that control how responses are stored and reused. Choosing the wrong cache option leads to either stale data or unnecessary network requests on every page load.

**Incorrect (default behavior without explicit cache strategy):**

```typescript
// app/lib/products.ts
export async function getProducts() {
  // No cache option - behavior varies between dev and production
  const response = await fetch('https://api.example.com/products')
  return response.json()
}

export async function getProductById(productId: string) {
  // Same issue - implicit caching behavior is unpredictable
  const response = await fetch(`https://api.example.com/products/${productId}`)
  return response.json()
}
```

**Correct (explicit cache strategy for each use case):**

```typescript
// app/lib/products.ts
export async function getProducts() {
  // Static catalog - cache aggressively, revalidate hourly
  const response = await fetch('https://api.example.com/products', {
    next: { revalidate: 3600 },
  })
  return response.json()
}

export async function getProductById(productId: string) {
  // Individual product - cache with tag for targeted invalidation
  const response = await fetch(`https://api.example.com/products/${productId}`, {
    next: { tags: [`product-${productId}`], revalidate: 3600 },
  })
  return response.json()
}
```

**Cache options reference:**

```typescript
// force-cache: Maximum caching, persists until manually invalidated
fetch(url, { cache: 'force-cache' })

// no-store: Always fetch fresh, bypasses all caching
fetch(url, { cache: 'no-store' })

// Time-based revalidation: Cache for N seconds
fetch(url, { next: { revalidate: 60 } })

// Tag-based: Cache with tags for on-demand invalidation
fetch(url, { next: { tags: ['products'] } })

// Combined: Tags with time-based fallback
fetch(url, { next: { tags: ['products'], revalidate: 3600 } })
```

**When to use each option:**

| Option | Use Case |
|--------|----------|
| `force-cache` | Truly static data (config, feature flags) |
| `no-store` | User-specific data, real-time prices |
| `revalidate: N` | Semi-static data (product catalog, blog posts) |
| `tags: [...]` | Data that changes on specific events |

Reference: [Next.js fetch caching](https://nextjs.org/docs/app/api-reference/functions/fetch)
