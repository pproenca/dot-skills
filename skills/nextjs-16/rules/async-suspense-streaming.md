---
title: Use Suspense for Streaming Dynamic Content
impact: CRITICAL
impactDescription: Reduces Time to First Byte (TTFB) by streaming static shell immediately; perceived load time improves 2-5×
tags: async, suspense, streaming, loading-states
---

## Use Suspense for Streaming Dynamic Content

Wrapping slow async components in Suspense boundaries allows Next.js to stream the static shell immediately while dynamic content loads. Users see something useful in 50-100ms instead of waiting 500ms+ for all data.

**Incorrect (blocking on slow data):**

```typescript
async function SlowRecommendations() {
  // 800ms API call
  const recs = await fetch('https://slow-api.com/recommendations').then(r => r.json())
  return <RecommendationList items={recs} />
}

export default async function ProductPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params
  const product = await getProduct(id)

  return (
    <main>
      <h1>{product.name}</h1>
      <p>{product.description}</p>
      {/* Entire page blocked for 800ms */}
      <SlowRecommendations />
    </main>
  )
}
```

**Correct (streaming with Suspense):**

```typescript
import { Suspense } from 'react'

async function SlowRecommendations() {
  const recs = await fetch('https://slow-api.com/recommendations').then(r => r.json())
  return <RecommendationList items={recs} />
}

export default async function ProductPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params
  const product = await getProduct(id)

  return (
    <main>
      {/* Static content sent immediately */}
      <h1>{product.name}</h1>
      <p>{product.description}</p>
      {/* Recommendations stream in when ready */}
      <Suspense fallback={<RecommendationSkeleton />}>
        <SlowRecommendations />
      </Suspense>
    </main>
  )
}
```

**Skeleton component example:**

```typescript
function RecommendationSkeleton() {
  return (
    <div className="space-y-4 animate-pulse">
      <div className="h-32 bg-gray-200 rounded" />
      <div className="h-32 bg-gray-200 rounded" />
      <div className="h-32 bg-gray-200 rounded" />
    </div>
  )
}
```

**When NOT to use this pattern:**
- Content is critical and must be visible before interaction (e.g., auth state)
- SEO-critical content that must be in initial HTML for crawlers

Reference: [Next.js Streaming](https://nextjs.org/docs/app/building-your-application/routing/loading-ui-and-streaming)
