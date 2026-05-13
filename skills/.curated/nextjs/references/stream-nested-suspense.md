---
title: Nest Suspense boundaries when content has a natural reveal order (critical → secondary → tertiary)
impact: LOW-MEDIUM
impactDescription: outer boundaries reveal first, inner refine progressively — creates a guided loading experience for hierarchical content
tags: stream, nested-suspense, progressive-disclosure, hierarchical-reveal
---

## Nest Suspense boundaries when content has a natural reveal order (critical → secondary → tertiary)

**Pattern intent:** some pages have a natural priority order (product details → reviews → related products; main article → comments → suggested reading). Nesting Suspense boundaries — outer waits for inner *or* allows inner to refine — creates a guided reveal.

### Shapes to recognize

- A product page with three sibling Suspense boundaries (details, reviews, related) all loading independently — works but loses the "details first, then reviews" ordering.
- A blog post showing comments and "related posts" at the same time as the article body — distracts from the primary content.
- A search results page where filters render at the same time as the result list — should be filters first, then results refine.
- Nested boundaries placed wrong: inner Suspense around fast content, outer around slow — the outer's fallback shows while inner is already done.
- A workaround using `setTimeout` in `useEffect` to "stagger" the reveal — manual choreography that nested Suspense does declaratively.

The canonical resolution: wrap the primary content's Suspense around the page; inside, nest a Suspense for secondary content; inside that, another for tertiary. Each level's fallback is a skeleton of *its* content; outer renders → inner fallback → inner content. The hierarchy is visible in the JSX.

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
