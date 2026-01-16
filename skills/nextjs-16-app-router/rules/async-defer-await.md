---
title: Start Fetches Early, Await When Value Needed
impact: CRITICAL
impactDescription: 30-60% faster data loading by overlapping fetch with computation
tags: async, defer, promises, optimization, performance
---

## Start Fetches Early, Await When Value Needed

When you await immediately, you block execution until the fetch completes. By starting fetches early (without await) and deferring the await until the value is needed, you allow fetches to run while other code executes, maximizing parallelism.

**Incorrect (await blocks immediately):**

```typescript
async function ProductPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params

  const product = await getProduct(id)       // Blocks here for 200ms
  const reviews = await getReviews(id)       // Then blocks here for 300ms

  // Expensive computation happens after both fetches complete
  const recommendations = computeRecommendations(product)
  const averageRating = calculateAverageRating(reviews)

  return (
    <div>
      <ProductDetails product={product} recommendations={recommendations} />
      <ReviewSection reviews={reviews} rating={averageRating} />
    </div>
  )
}
// Total: 500ms fetch + computation time
```

**Correct (start early, await when needed):**

```typescript
async function ProductPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params

  // Start fetches immediately (no await)
  const productPromise = getProduct(id)
  const reviewsPromise = getReviews(id)

  // Await only when values are needed
  const product = await productPromise       // 200ms elapsed
  const recommendations = computeRecommendations(product)  // Runs while reviews fetch continues

  const reviews = await reviewsPromise       // May already be complete
  const averageRating = calculateAverageRating(reviews)

  return (
    <div>
      <ProductDetails product={product} recommendations={recommendations} />
      <ReviewSection reviews={reviews} rating={averageRating} />
    </div>
  )
}
// Total: 300ms (fetches overlap with computation)
```

**Alternative (pass promises to child components):**

```typescript
async function ProductPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params

  // Start fetches, pass promises down
  const productPromise = getProduct(id)
  const reviewsPromise = getReviews(id)

  return (
    <div>
      <Suspense fallback={<ProductSkeleton />}>
        <ProductDetails productPromise={productPromise} />
      </Suspense>
      <Suspense fallback={<ReviewsSkeleton />}>
        <ReviewSection reviewsPromise={reviewsPromise} />
      </Suspense>
    </div>
  )
}

// Child component awaits the promise
async function ProductDetails({
  productPromise
}: {
  productPromise: Promise<Product>
}) {
  const product = await productPromise
  return <div>{product.name}</div>
}
```

**Benefits:**
- Fetches start immediately instead of waiting for previous code
- Computation and I/O can happen concurrently
- Enables streaming when combined with Suspense

Reference: [Data Fetching Patterns](https://nextjs.org/docs/app/getting-started/fetching-data)
