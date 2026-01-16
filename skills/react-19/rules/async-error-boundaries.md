---
title: Pair Suspense with Error Boundaries
impact: HIGH
impactDescription: prevents unhandled promise rejections from crashing the UI
tags: async, suspense, error-boundaries, error-handling
---

## Pair Suspense with Error Boundaries

When a promise passed to `use` rejects, it throws an error. Without an Error Boundary, this crashes the component tree. Always wrap Suspense boundaries with Error Boundaries for resilient data fetching.

**Incorrect (rejected promise crashes the page):**

```tsx
function ProductPage({ productId }: { productId: string }) {
  return (
    <Suspense fallback={<ProductSkeleton />}>
      <ProductDetails productId={productId} />
    </Suspense>
  )
}

function ProductDetails({ productId }: { productId: string }) {
  const product = use(fetchProduct(productId))  // Throws on 404
  return <div>{product.name}</div>
}
// 404 crashes the entire page
```

**Correct (error boundary provides fallback):**

```tsx
function ProductPage({ productId }: { productId: string }) {
  return (
    <ErrorBoundary
      fallback={<ProductError />}
      onError={(error) => logError(error)}
    >
      <Suspense fallback={<ProductSkeleton />}>
        <ProductDetails productId={productId} />
      </Suspense>
    </ErrorBoundary>
  )
}

function ProductDetails({ productId }: { productId: string }) {
  const product = use(fetchProduct(productId))
  return <div>{product.name}</div>
}

function ProductError() {
  return (
    <div className="error-state">
      <h2>Product not found</h2>
      <Link href="/products">Browse all products</Link>
    </div>
  )
}
```

**With retry capability:**

```tsx
function ProductPage({ productId }: { productId: string }) {
  const [key, setKey] = useState(0)

  return (
    <ErrorBoundary
      key={key}
      fallback={
        <div>
          <p>Failed to load product</p>
          <button onClick={() => setKey(k => k + 1)}>Retry</button>
        </div>
      }
    >
      <Suspense fallback={<ProductSkeleton />}>
        <ProductDetails productId={productId} />
      </Suspense>
    </ErrorBoundary>
  )
}
```

Reference: [Error Boundaries with Suspense](https://react.dev/reference/react/Suspense#providing-a-fallback-for-server-errors-and-client-only-content)
