---
title: Nest Suspense for Progressive Disclosure
impact: LOW-MEDIUM
impactDescription: fine-grained loading control, better UX
tags: stream, suspense, nested, progressive
---

## Nest Suspense for Progressive Disclosure

Nest Suspense boundaries to create progressive loading experiences. Outer boundaries show first, inner boundaries refine as data loads.

**Incorrect (flat Suspense structure):**

```typescript
export default function ProductPage() {
  return (
    <div>
      <Suspense fallback={<ProductSkeleton />}>
        <ProductDetails />
      </Suspense>
      <Suspense fallback={<ReviewsSkeleton />}>
        <Reviews />
      </Suspense>
      <Suspense fallback={<RelatedSkeleton />}>
        <RelatedProducts />
      </Suspense>
    </div>
  )
}
// All sections load independently, no visual hierarchy
```

**Correct (nested progressive disclosure):**

```typescript
export default function ProductPage() {
  return (
    <div>
      {/* Product details load first - critical content */}
      <Suspense fallback={<ProductSkeleton />}>
        <ProductDetails />

        {/* Reviews load after product - secondary content */}
        <Suspense fallback={<ReviewsSkeleton />}>
          <Reviews />

          {/* Related products load last - tertiary content */}
          <Suspense fallback={<RelatedSkeleton />}>
            <RelatedProducts />
          </Suspense>
        </Suspense>
      </Suspense>
    </div>
  )
}
// Content reveals progressively: Product → Reviews → Related
```

**Alternative (prioritized parallel loading):**

```typescript
export default function ProductPage() {
  return (
    <div>
      {/* Critical path - no Suspense, blocks render */}
      <ProductHeader />

      <div className="grid grid-cols-2 gap-8">
        {/* Primary content */}
        <Suspense fallback={<DetailsSkeleton />}>
          <ProductDetails />
        </Suspense>

        {/* Secondary content - lower priority */}
        <Suspense fallback={<SidebarSkeleton />}>
          <ProductSidebar />
        </Suspense>
      </div>
    </div>
  )
}
```
