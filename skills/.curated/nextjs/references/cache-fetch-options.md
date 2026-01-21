---
title: Configure Fetch Cache Options Correctly
impact: HIGH
impactDescription: controls data freshness per request
tags: cache, fetch, revalidate, data-fetching
---

## Configure Fetch Cache Options Correctly

The `fetch` API in Server Components supports cache configuration. Understand the three modes: force-cache (default), no-store, and time-based revalidation.

**Incorrect (mixing cache strategies without intent):**

```typescript
export default async function Page() {
  // Static data that rarely changes - correct
  const config = await fetch('https://api.example.com/config')

  // User-specific data that should be fresh - WRONG
  const user = await fetch(`https://api.example.com/users/${userId}`)
  // Using default caching for dynamic data!
}
```

**Correct (explicit cache strategies):**

```typescript
export default async function Page() {
  // Static data - cache indefinitely
  const config = await fetch('https://api.example.com/config', {
    cache: 'force-cache'
  })

  // Dynamic data - never cache
  const user = await fetch(`https://api.example.com/users/${userId}`, {
    cache: 'no-store'
  })

  // Semi-dynamic - revalidate every 5 minutes
  const products = await fetch('https://api.example.com/products', {
    next: { revalidate: 300 }
  })

  // Tagged for on-demand revalidation
  const posts = await fetch('https://api.example.com/posts', {
    next: { tags: ['posts'] }
  })
}
```

**Cache strategy decision tree:**
- User-specific or real-time → `no-store`
- Changes hourly/daily → `next: { revalidate: N }`
- Static/rarely changes → `force-cache`
- Needs on-demand invalidation → `next: { tags: [...] }`
