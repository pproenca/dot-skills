---
title: Profile Before Optimizing to Target Real Bottlenecks
impact: MEDIUM
impactDescription: 10× faster bottleneck identification
tags: profile, measurement, bottleneck, premature-optimization
---

## Profile Before Optimizing to Target Real Bottlenecks

Most components render in under 1ms and gain nothing from memoization. Optimizing without profiling wastes engineering time on fast components while the actual bottleneck — often a single expensive subtree — remains untouched.

**Incorrect (memoizing cheap components without measurement):**

```tsx
// Developer assumes ProductCard is slow and wraps everything in memo
const ProductCard = memo(function ProductCard({ product }: { product: Product }) {
  return (
    <div className="product-card">
      <h3>{product.name}</h3>
      <p>${product.price.toFixed(2)}</p>
      <span className={`badge-${product.availability}`}>
        {product.availability}
      </span>
    </div>
  )
})

// Meanwhile, the actual bottleneck is an unvirtualized search results list
// rendering 2000 items that takes 400ms per render — never profiled
function SearchResults({ results }: { results: Product[] }) {
  return (
    <div>
      {results.map((product) => (
        <ProductCard key={product.id} product={product} />
      ))}
    </div>
  )
}
```

**Correct (profile first, then optimize the measured bottleneck):**

```tsx
// Step 1: Profile with React DevTools Profiler
// Found: SearchResults renders 2000 items in 400ms
// Found: ProductCard renders in 0.3ms each — not the issue

// Step 2: Fix the actual bottleneck — virtualize the long list
import { useVirtualizer } from "@tanstack/react-virtual"

function SearchResults({ results }: { results: Product[] }) {
  const scrollRef = useRef<HTMLDivElement>(null)
  const virtualizer = useVirtualizer({
    count: results.length,
    getScrollElement: () => scrollRef.current,
    estimateSize: () => 96,
  })

  return (
    <div ref={scrollRef} style={{ height: 600, overflow: "auto" }}>
      <div style={{ height: virtualizer.getTotalSize(), position: "relative" }}>
        {virtualizer.getVirtualItems().map((row) => (
          <div
            key={results[row.index].id}
            style={{ position: "absolute", top: row.start, height: row.size, width: "100%" }}
          >
            <ProductCard product={results[row.index]} />
          </div>
        ))}
      </div>
    </div>
  )
}

// No memo needed — ProductCard was never the bottleneck
function ProductCard({ product }: { product: Product }) {
  return (
    <div className="product-card">
      <h3>{product.name}</h3>
      <p>${product.price.toFixed(2)}</p>
      <span className={`badge-${product.availability}`}>
        {product.availability}
      </span>
    </div>
  )
}
```

Reference: [React Docs — React DevTools Profiler](https://react.dev/learn/react-developer-tools)
