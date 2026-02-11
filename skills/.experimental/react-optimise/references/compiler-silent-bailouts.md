---
title: Detect and Fix Silent Compiler Bailouts
impact: CRITICAL
impactDescription: prevents losing automatic memoization on affected components
tags: compiler, bailout, diagnostics, idiomatic
---

## Detect and Fix Silent Compiler Bailouts

React Compiler silently skips optimization when it encounters patterns it cannot prove safe: try/catch wrapping render expressions, optional chaining on refs, spreading unknown objects, and class component patterns. These bailouts produce no warnings -- the component just runs without memoization.

**Incorrect (three silent bailout patterns):**

```tsx
function ProductDetail({ productId }: { productId: string }) {
  const containerRef = useRef<HTMLDivElement>(null)

  // Bailout: try/catch in render path
  let product: Product
  try {
    product = parseProductData(productId)
  } catch {
    product = FALLBACK_PRODUCT
  }

  // Bailout: optional chaining on ref during render
  const containerWidth = containerRef.current?.offsetWidth ?? 0

  // Bailout: spreading an object the compiler cannot statically analyze
  const analyticsProps = getAnalyticsProps(productId)

  return (
    <div ref={containerRef}>
      <ProductCard
        name={product.name}
        price={product.price}
        width={containerWidth}
        {...analyticsProps}
      />
    </div>
  )
}
```

**Correct (compiler-safe alternatives):**

```tsx
function ProductDetail({ productId }: { productId: string }) {
  const containerRef = useRef<HTMLDivElement>(null)
  const [containerWidth, setContainerWidth] = useState(0)

  useEffect(() => {
    if (containerRef.current) {
      setContainerWidth(containerRef.current.offsetWidth)
    }
  }, [])

  const product = parseProductData(productId) ?? FALLBACK_PRODUCT

  const analyticsProps = getAnalyticsProps(productId)

  return (
    <div ref={containerRef}>
      <ProductCard
        name={product.name}
        price={product.price}
        width={containerWidth}
        data-track-id={analyticsProps.trackId}
        data-track-source={analyticsProps.trackSource}
      />
    </div>
  )
}
```

Reference: [React Compiler — Troubleshooting](https://react.dev/learn/react-compiler#troubleshooting)
