---
title: Calculate Derived Values During Render
impact: MEDIUM
impactDescription: eliminates sync bugs, simpler code
tags: state, derived, calculation, render
---

## Calculate Derived Values During Render

Don't store values that can be calculated from existing state or props. Calculate them during render instead.

**Incorrect (derived state in useState):**

```typescript
function ProductList({ products }: { products: Product[] }) {
  const [filter, setFilter] = useState('')
  const [filteredProducts, setFilteredProducts] = useState(products)

  useEffect(() => {
    setFilteredProducts(
      products.filter(p => p.name.includes(filter))
    )
  }, [products, filter])
  // Extra state, effect, potential sync bugs

  return (
    <div>
      <input value={filter} onChange={e => setFilter(e.target.value)} />
      {filteredProducts.map(p => <ProductCard key={p.id} product={p} />)}
    </div>
  )
}
```

**Correct (calculated during render):**

```typescript
function ProductList({ products }: { products: Product[] }) {
  const [filter, setFilter] = useState('')

  // Calculated during render - always in sync
  const filteredProducts = products.filter(p =>
    p.name.toLowerCase().includes(filter.toLowerCase())
  )

  return (
    <div>
      <input value={filter} onChange={e => setFilter(e.target.value)} />
      {filteredProducts.map(p => <ProductCard key={p.id} product={p} />)}
    </div>
  )
}
```

**With memoization for expensive calculations:**

```typescript
function ProductList({ products }: { products: Product[] }) {
  const [filter, setFilter] = useState('')

  const filteredProducts = useMemo(() =>
    products.filter(p => expensiveMatch(p, filter)),
    [products, filter]
  )

  return (/* ... */)
}
```

Reference: [You Might Not Need an Effect](https://react.dev/learn/you-might-not-need-an-effect)
