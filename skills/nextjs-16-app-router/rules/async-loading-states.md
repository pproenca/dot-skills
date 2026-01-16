---
title: Use loading.tsx for Instant Navigation Feedback
impact: CRITICAL
impactDescription: 0ms perceived latency vs 1-3s blank screen
tags: async, loading, skeleton, navigation, ux
---

## Use loading.tsx for Instant Navigation Feedback

Without loading.tsx, users see no feedback during navigation to dynamic routes - the page appears frozen. The loading.tsx file creates an automatic Suspense boundary that displays immediately, providing instant visual feedback while server content renders.

**Incorrect (no loading state, navigation feels broken):**

```typescript
// app/products/[id]/page.tsx
export default async function ProductPage({
  params,
}: {
  params: Promise<{ id: string }>
}) {
  const { id } = await params
  const product = await getProduct(id)  // 800ms with no visual feedback
  const reviews = await getReviews(id)  // 400ms more of blank screen

  return (
    <div>
      <ProductDetails product={product} />
      <ReviewList reviews={reviews} />
    </div>
  )
}
// User clicks link, nothing happens for 1.2 seconds
```

**Correct (loading.tsx provides instant feedback):**

```typescript
// app/products/[id]/loading.tsx
export default function Loading() {
  return (
    <div className="product-page">
      <ProductDetailsSkeleton />
      <ReviewListSkeleton />
    </div>
  )
}

// app/products/[id]/page.tsx
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

  return (
    <div>
      <ProductDetails product={product} />
      <ReviewList reviews={reviews} />
    </div>
  )
}
// User clicks link, skeleton appears instantly
```

**Alternative (granular loading with nested Suspense):**

```typescript
// app/products/[id]/loading.tsx
export default function Loading() {
  return <ProductDetailsSkeleton />  // Just the critical section
}

// app/products/[id]/page.tsx
import { Suspense } from 'react'

export default async function ProductPage({
  params,
}: {
  params: Promise<{ id: string }>
}) {
  const { id } = await params
  const product = await getProduct(id)

  return (
    <div>
      <ProductDetails product={product} />
      <Suspense fallback={<ReviewListSkeleton />}>
        <ReviewList productId={id} />  {/* Streams in separately */}
      </Suspense>
    </div>
  )
}
```

**Benefits:**
- Navigation triggers instantly instead of waiting for server
- Users understand the app is responding
- Skeleton layouts prevent layout shift when content loads
- Enables partial prefetching for dynamic routes

**Best practices for loading.tsx:**
- Match the skeleton structure to the actual page layout
- Keep skeletons lightweight (no data fetching)
- Use consistent skeleton components across similar pages
- Consider animated placeholders for better perceived performance

Reference: [Loading UI and Streaming](https://nextjs.org/docs/app/api-reference/file-conventions/loading)
