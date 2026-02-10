---
title: Leverage React Compiler for Automatic Memoization
impact: MEDIUM
impactDescription: automatic optimization, less manual code
tags: memo, compiler, automatic, optimization
---

## Leverage React Compiler for Automatic Memoization

React Compiler v1.0 (released October 2025) automatically memoizes components and values. It's a standalone build-time tool that works with React 17+. Reduce manual useMemo/useCallback when compiler is enabled.

**Incorrect (verbose manual memoization):**

```typescript
function ProductPage({ product }: { product: Product }) {
  const formattedPrice = useMemo(() =>
    formatCurrency(product.price),
    [product.price]
  )

  const handleAddToCart = useCallback(() => {
    addToCart(product.id)
  }, [product.id])

  const relatedProducts = useMemo(() =>
    products.filter(p => p.category === product.category),
    [products, product.category]
  )

  return (
    <div>
      <h1>{product.name}</h1>
      <p>{formattedPrice}</p>
      <AddButton onClick={handleAddToCart} />
      <RelatedList products={relatedProducts} />
    </div>
  )
}
// Lots of manual memoization boilerplate
```

**Correct (React Compiler handles memoization):**

```typescript
function ProductPage({ product }: { product: Product }) {
  // Compiler automatically memoizes these
  const formattedPrice = formatCurrency(product.price)

  function handleAddToCart() {
    addToCart(product.id)
  }

  const relatedProducts = products.filter(
    p => p.category === product.category
  )

  return (
    <div>
      <h1>{product.name}</h1>
      <p>{formattedPrice}</p>
      <AddButton onClick={handleAddToCart} />
      <RelatedList products={relatedProducts} />
    </div>
  )
}
// Cleaner code, compiler handles memoization
```

**Enabling React Compiler:**

```bash
npm install --save-dev --save-exact babel-plugin-react-compiler@latest
```

```javascript
// babel.config.js
module.exports = {
  plugins: [
    ['babel-plugin-react-compiler', {}]
  ]
}
```

**For React 17/18 projects**, also add `react-compiler-runtime`:

```bash
npm install react-compiler-runtime
```

```javascript
// babel.config.js
module.exports = {
  plugins: [
    ['babel-plugin-react-compiler', { target: '18' }]
  ]
}
```

**Note:** `eslint-plugin-react-compiler` is deprecated — compiler rules are now in `eslint-plugin-react-hooks@latest`. Still use manual memoization for edge cases the compiler can't optimize, and measure with React Profiler.
