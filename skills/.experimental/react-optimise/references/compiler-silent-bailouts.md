---
title: Detect and Fix Silent Compiler Bailouts
impact: CRITICAL
impactDescription: prevents losing automatic memoization on affected components
tags: compiler, bailout, diagnostics, idiomatic
---

## Detect and Fix Silent Compiler Bailouts

React Compiler silently skips optimization when it encounters patterns it cannot prove safe: try/catch wrapping render expressions, optional chaining on refs during render, mutating values during render, and class component patterns. These bailouts produce no warnings — the component just runs without memoization.

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

  // Bailout: mutating an object during render
  const config = { theme: "light" }
  config.theme = getUserTheme(productId) // mutation breaks compiler tracking

  return (
    <div ref={containerRef}>
      <ProductCard
        name={product.name}
        price={product.price}
        width={containerWidth}
        theme={config.theme}
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

  const theme = getUserTheme(productId) // compute directly, no mutation

  return (
    <div ref={containerRef}>
      <ProductCard
        name={product.name}
        price={product.price}
        width={containerWidth}
        theme={theme}
      />
    </div>
  )
}
```

Reference: [React Compiler — Troubleshooting](https://react.dev/learn/react-compiler#troubleshooting)
