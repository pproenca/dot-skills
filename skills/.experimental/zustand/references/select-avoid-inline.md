---
title: Define Selectors Outside Components
impact: HIGH
impactDescription: prevents selector recreation on every render
tags: select, performance, inline, stability
---

## Define Selectors Outside Components

Define selector functions outside components or memoize them. Inline selectors are recreated on every render, which can cause subtle performance issues with complex selectors.

**Incorrect (inline selector recreated every render):**

```typescript
function ProductList() {
  // This selector function is recreated on every render
  const expensiveProducts = useProductStore((state) =>
    state.products
      .filter((p) => p.price > 100)
      .sort((a, b) => b.price - a.price)
      .slice(0, 10)
  )

  return <ProductGrid products={expensiveProducts} />
}
```

**Correct (selector defined outside):**

```typescript
// Selector defined once, reused
const selectExpensiveProducts = (state: ProductState) =>
  state.products
    .filter((p) => p.price > 100)
    .sort((a, b) => b.price - a.price)
    .slice(0, 10)

function ProductList() {
  // Same function reference on every render
  const expensiveProducts = useProductStore(
    useShallow(selectExpensiveProducts)
  )

  return <ProductGrid products={expensiveProducts} />
}
```

**Alternative (custom hook encapsulation):**

```typescript
// Encapsulate in custom hook
const useExpensiveProducts = () => {
  return useProductStore(
    useShallow((state) =>
      state.products
        .filter((p) => p.price > 100)
        .sort((a, b) => b.price - a.price)
        .slice(0, 10)
    )
  )
}

function ProductList() {
  const expensiveProducts = useExpensiveProducts()
  return <ProductGrid products={expensiveProducts} />
}
```

**Note:** For simple atomic selectors like `(s) => s.count`, inline is fine because the cost is negligible. This matters most for selectors that:
- Transform data (filter, map, sort)
- Create new objects or arrays
- Perform expensive computations

Reference: [Zustand Documentation](https://zustand.docs.pmnd.rs/)
