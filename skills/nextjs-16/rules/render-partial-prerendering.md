---
title: Use Partial Prerendering for Mixed Content
impact: MEDIUM-HIGH
impactDescription: Combines static shell with dynamic holes; static content renders in <50ms while dynamic streams in without blocking
tags: render, PPR, partial-prerendering, streaming
---

## Use Partial Prerendering for Mixed Content

Partial Prerendering (PPR) serves a static shell immediately while dynamic content streams in. This gives you the speed of static pages with the freshness of dynamic content. Wrap dynamic parts in Suspense boundaries.

**Incorrect (fully dynamic page):**

```typescript
// Entire page waits for user data
import { cookies } from 'next/headers'

export default async function ProductPage({
  params,
}: {
  params: Promise<{ id: string }>
}) {
  const { id } = await params
  const cookieStore = await cookies()
  const userId = cookieStore.get('userId')?.value

  const product = await getProduct(id)  // Static data
  const recommendations = await getRecommendations(id, userId)  // Dynamic

  return (
    <div>
      <ProductInfo product={product} />
      <Recommendations items={recommendations} />
    </div>
  )
}
// Entire page renders dynamically due to cookies()
```

**Correct (PPR with static shell + dynamic holes):**

```typescript
import { Suspense } from 'react'

export default async function ProductPage({
  params,
}: {
  params: Promise<{ id: string }>
}) {
  const { id } = await params
  const product = await getProduct(id)  // Cached, part of static shell

  return (
    <div>
      {/* Static: pre-rendered at build time */}
      <ProductInfo product={product} />

      {/* Dynamic: streams in at request time */}
      <Suspense fallback={<RecommendationsSkeleton />}>
        <PersonalizedRecommendations productId={id} />
      </Suspense>
    </div>
  )
}

// This component uses cookies, making it dynamic
async function PersonalizedRecommendations({ productId }: { productId: string }) {
  const cookieStore = await cookies()
  const userId = cookieStore.get('userId')?.value

  const recommendations = await getRecommendations(productId, userId)
  return <Recommendations items={recommendations} />
}
```

**Enable PPR in next.config.js:**

```javascript
// next.config.js
module.exports = {
  experimental: {
    ppr: true,
  },
}
```

**PPR with Cache Components (Next.js 16):**

```typescript
import { Suspense } from 'react'
import { cacheLife } from 'next/cache'

async function CachedProductInfo({ id }: { id: string }) {
  'use cache'
  cacheLife('days')

  const product = await getProduct(id)
  return <ProductInfo product={product} />
}

export default async function ProductPage({
  params,
}: {
  params: Promise<{ id: string }>
}) {
  const { id } = await params

  return (
    <div>
      <CachedProductInfo id={id} />
      <Suspense fallback={<RecommendationsSkeleton />}>
        <PersonalizedRecommendations productId={id} />
      </Suspense>
    </div>
  )
}
```

**Pattern: PPR for e-commerce:**
- **Static shell**: Product images, descriptions, prices, navigation
- **Dynamic holes**: Cart count, personalized recommendations, stock status

**When NOT to use PPR:**
- Entire page is personalized (dashboard)
- Data changes every request (real-time feeds)
- Page is already fully static

Reference: [Next.js Partial Prerendering](https://nextjs.org/docs/app/building-your-application/rendering/partial-prerendering)
