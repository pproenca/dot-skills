---
title: Trust the Compiler for Memoization
impact: HIGH
impactDescription: removes 80% of manual useMemo/useCallback, cleaner code
tags: compiler, memoization, useMemo, useCallback, optimization
---

## Trust the Compiler for Memoization

React Compiler automatically memoizes values and callbacks at build time. Manual useMemo and useCallback are usually unnecessary and add code complexity without improving performance.

**Incorrect (manual memoization everywhere):**

```tsx
function ProductList({ products, onSelect }: Props) {
  const sortedProducts = useMemo(
    () => [...products].sort((a, b) => a.price - b.price),
    [products]
  )

  const handleSelect = useCallback(
    (id: string) => onSelect(id),
    [onSelect]
  )

  const formatPrice = useCallback(
    (price: number) => `$${price.toFixed(2)}`,
    []
  )

  return (
    <ul>
      {sortedProducts.map(product => (
        <ProductItem
          key={product.id}
          product={product}
          onSelect={handleSelect}
          formatPrice={formatPrice}
        />
      ))}
    </ul>
  )
}
```

**Correct (let compiler optimize):**

```tsx
function ProductList({ products, onSelect }: Props) {
  const sortedProducts = [...products].sort((a, b) => a.price - b.price)

  const handleSelect = (id: string) => onSelect(id)

  const formatPrice = (price: number) => `$${price.toFixed(2)}`

  return (
    <ul>
      {sortedProducts.map(product => (
        <ProductItem
          key={product.id}
          product={product}
          onSelect={handleSelect}
          formatPrice={formatPrice}
        />
      ))}
    </ul>
  )
}
// Compiler automatically memoizes what needs memoizing
```

**When manual memoization is still needed:**
- Third-party libraries requiring stable references
- Values used as effect dependencies with specific identity requirements
- Opting out of compiler optimization for debugging

Reference: [React Compiler Introduction](https://react.dev/learn/react-compiler/introduction)
