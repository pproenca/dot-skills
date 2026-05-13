---
title: Adopt React Compiler v1.0 — let the build memoize, then remove the manual `useMemo`/`useCallback` noise
impact: MEDIUM
impactDescription: removes large amounts of manual memoization code; works with React 17+; the compiler handles most cases the eye can see
tags: memo, react-compiler, auto-memoization, compiler-enabled
---

## Adopt React Compiler v1.0 — let the build memoize, then remove the manual `useMemo`/`useCallback` noise

**Pattern intent:** as of React Compiler v1.0 (October 2025), the build can hoist most reference-stability and recomputation concerns out of source. Once the compiler is enabled, the manual `useMemo`/`useCallback` wrappers that previously did this work add noise without value. New code should be written compiler-naïve; old code can be progressively de-memoized.

### Shapes to recognize

- A codebase with the compiler enabled but every value/callback still wrapped — leftover from pre-compiler conventions; codemod it back to plain expressions.
- A new file in a compiler-enabled project that imports `useMemo`/`useCallback` for trivial expressions — the author was writing pre-compiler React.
- Build config that lists `babel-plugin-react-compiler` but a custom Babel order/preset stops it from running on app code — the plugin is configured but inert.
- An ESLint config that still references the deprecated `eslint-plugin-react-compiler` instead of `eslint-plugin-react-hooks@latest` (compiler rules moved there).
- A React 17/18 project trying to install only `babel-plugin-react-compiler` and seeing runtime errors — `react-compiler-runtime` is required for pre-19 targets.

The canonical resolution: install `babel-plugin-react-compiler@latest` (and `react-compiler-runtime` for React 17/18 targets), enable in Babel config, switch ESLint to `eslint-plugin-react-hooks@latest`. Write new code without manual memoization. Codemod existing manual memos away over time, measuring with React Profiler that the change is neutral or positive.

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
