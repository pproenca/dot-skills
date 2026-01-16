---
title: Preload Data to Avoid Waterfalls
impact: HIGH
impactDescription: eliminates parent-child fetch waterfalls
tags: server, preload, waterfalls, data-fetching, cache
---

## Preload Data to Avoid Waterfalls

In Server Component trees, child components can't start fetching until their parent finishes rendering. Use the preload pattern to start fetches early and deduplicate with cache().

**Incorrect (waterfall between parent and child):**

```tsx
// Parent fetches, then child fetches sequentially
async function ProductPage({ productId }: { productId: string }) {
  const product = await getProduct(productId)  // 200ms

  return (
    <div>
      <ProductDetails product={product} />
      <ReviewSection productId={productId} />  {/* Can't start until parent done */}
    </div>
  )
}

async function ReviewSection({ productId }: { productId: string }) {
  const reviews = await getReviews(productId)  // 300ms (starts after 200ms)
  return <ReviewList reviews={reviews} />
}
// Total: 500ms
```

**Correct (preload eliminates waterfall):**

```tsx
// lib/data.ts
import { cache } from 'react'

export const getProduct = cache(async (id: string) => {
  return db.product.findUnique({ where: { id } })
})

export const getReviews = cache(async (productId: string) => {
  return db.review.findMany({ where: { productId } })
})

// Preload function starts fetches without awaiting
export function preloadProductData(productId: string) {
  void getProduct(productId)
  void getReviews(productId)
}

// Page starts both fetches immediately
async function ProductPage({ productId }: { productId: string }) {
  preloadProductData(productId)  // Start both fetches

  const product = await getProduct(productId)  // Already in flight

  return (
    <div>
      <ProductDetails product={product} />
      <ReviewSection productId={productId} />
    </div>
  )
}

async function ReviewSection({ productId }: { productId: string }) {
  const reviews = await getReviews(productId)  // Returns cached/in-flight result
  return <ReviewList reviews={reviews} />
}
// Total: 300ms (max of both)
```

Reference: [Preloading Data](https://react.dev/reference/react/cache#preload-data)
