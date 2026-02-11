---
title: Isolate Side Effects from Render for Compiler Correctness
impact: CRITICAL
impactDescription: prevents compiler from producing incorrect cached output
tags: compiler, side-effects, purity, correctness
---

## Isolate Side Effects from Render for Compiler Correctness

React Compiler assumes the render phase is pure and caches its output. Side effects executed during render -- analytics calls, logging, DOM measurements, or external store writes -- run fewer times than expected when the compiler skips re-renders. This produces stale analytics, missing log entries, and inconsistent state.

**Incorrect (side effects in render are skipped when compiler caches):**

```tsx
function ProductPage({ product }: { product: Product }) {
  analytics.track("product_viewed", { productId: product.id }) // skipped on cached renders

  console.log(`Rendering product: ${product.name}`) // fires unpredictably

  document.title = `${product.name} | Store` // DOM mutation in render

  const [quantity, setQuantity] = useState(1)
  const subtotal = product.price * quantity

  return (
    <div>
      <h1>{product.name}</h1>
      <span>${subtotal.toFixed(2)}</span>
      <button onClick={() => setQuantity((q) => q + 1)}>Add</button>
    </div>
  )
}
```

**Correct (side effects in effects and handlers, render stays pure):**

```tsx
function ProductPage({ product }: { product: Product }) {
  const [quantity, setQuantity] = useState(1)
  const subtotal = product.price * quantity

  useEffect(() => {
    analytics.track("product_viewed", { productId: product.id })
    document.title = `${product.name} | Store`
  }, [product.id, product.name])

  return (
    <div>
      <h1>{product.name}</h1>
      <span>${subtotal.toFixed(2)}</span>
      <button onClick={() => setQuantity((q) => q + 1)}>Add</button>
    </div>
  )
}
```

Reference: [React — Keeping Components Pure](https://react.dev/learn/keeping-components-pure)
