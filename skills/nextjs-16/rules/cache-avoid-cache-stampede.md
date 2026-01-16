---
title: Prevent Cache Stampedes with ISR
impact: MEDIUM
impactDescription: Single function invocation serves thousands of concurrent requests; prevents origin overload when cache expires
tags: cache, ISR, stampede, revalidation
---

## Prevent Cache Stampedes with ISR

When cache expires and many users request the same page simultaneously, each request could trigger its own server render (cache stampede). Incremental Static Regeneration (ISR) prevents this by serving stale content while one background process regenerates.

**Incorrect (no ISR protection):**

```typescript
// Dynamic page without ISR
// If 1000 users hit this when data is stale, 1000 renders execute
export default async function PopularPage() {
  const data = await fetch('https://api.example.com/popular', {
    cache: 'no-store'  // ❌ No caching = every request hits origin
  }).then(r => r.json())

  return <Display data={data} />
}
```

**Correct (ISR prevents stampede):**

```typescript
// ISR: serve stale, revalidate in background
export default async function PopularPage() {
  const data = await fetch('https://api.example.com/popular', {
    next: { revalidate: 60 }  // ✓ Cache 60s, background revalidation
  }).then(r => r.json())

  return <Display data={data} />
}

// 1000 users hit this page at cache expiry:
// - All 1000 get the stale cached version (instant)
// - ONE background process regenerates the page
// - Next requests get fresh content
```

**ISR with static generation:**

```typescript
// Combine generateStaticParams with revalidation
export async function generateStaticParams() {
  const products = await getPopularProducts()
  return products.map(p => ({ id: p.id }))
}

// Page component
export default async function ProductPage({ params }) {
  // ...
}

// Force ISR revalidation interval
export const revalidate = 3600  // Revalidate every hour
```

**Vercel's request collapsing:**
On Vercel, ISR includes automatic request collapsing - when multiple requests hit an uncached path:
- Only ONE invocation runs
- Other requests wait for that result
- All receive the same response

**Manual stale-while-revalidate pattern:**

```typescript
import { cacheLife } from 'next/cache'

async function getPopularData() {
  'use cache'
  cacheLife({
    stale: 300,      // Serve stale for 5 minutes while revalidating
    revalidate: 60,  // Background revalidation every 1 minute
    expire: 3600,    // Hard expire after 1 hour
  })

  return fetch('https://api.example.com/popular').then(r => r.json())
}
```

**High-traffic scenarios:**
- Product pages during flash sales
- News articles when breaking news hits
- API endpoints behind rate-limited services
- Pages with expensive database queries

**When NOT to use ISR:**
- Data must be real-time (use dynamic rendering)
- Page is fully personalized (no shared cache benefit)
- Low-traffic pages (stampede unlikely)

Reference: [Vercel ISR](https://vercel.com/docs/incremental-static-regeneration)
