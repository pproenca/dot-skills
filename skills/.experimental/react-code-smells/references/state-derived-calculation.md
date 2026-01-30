---
title: Replace Synchronized State with Derived Calculations
impact: CRITICAL
impactDescription: eliminates sync bugs, removes 30-50% of state variables
tags: state, derived-state, calculation, synchronization, refactoring
---

## Replace Synchronized State with Derived Calculations

State that can be computed from other state creates synchronization bugs. Calculate derived values during render instead.

**Code Smell Indicators:**
- Two useState calls where one depends on the other
- useEffect that sets state based on other state
- Bugs where values get out of sync
- State named `filteredItems`, `sortedList`, `isValid`

**Incorrect (synchronized state that drifts):**

```tsx
function ProductList({ products }) {
  const [searchTerm, setSearchTerm] = useState('')
  const [filteredProducts, setFilteredProducts] = useState(products)
  const [productCount, setProductCount] = useState(products.length)

  // Bug: these can get out of sync
  useEffect(() => {
    const filtered = products.filter(p =>
      p.name.toLowerCase().includes(searchTerm.toLowerCase())
    )
    setFilteredProducts(filtered)
    setProductCount(filtered.length)
  }, [searchTerm, products])

  return (
    <div>
      <input value={searchTerm} onChange={e => setSearchTerm(e.target.value)} />
      <p>{productCount} products</p>
      {filteredProducts.map(p => <Product key={p.id} {...p} />)}
    </div>
  )
}
```

**Correct (calculated during render):**

```tsx
function ProductList({ products }) {
  const [searchTerm, setSearchTerm] = useState('')

  // Derived values - always in sync
  const filteredProducts = products.filter(p =>
    p.name.toLowerCase().includes(searchTerm.toLowerCase())
  )
  const productCount = filteredProducts.length

  return (
    <div>
      <input value={searchTerm} onChange={e => setSearchTerm(e.target.value)} />
      <p>{productCount} products</p>
      {filteredProducts.map(p => <Product key={p.id} {...p} />)}
    </div>
  )
}
```

**For expensive calculations, use useMemo:**

```tsx
const filteredProducts = useMemo(
  () => products.filter(p =>
    p.name.toLowerCase().includes(searchTerm.toLowerCase())
  ),
  [products, searchTerm]
)
```

**Principal engineer judgment:**
- Default to calculation during render
- Only add useMemo when you've measured a performance problem
- If the calculation causes visible lag (>16ms), then memoize

Reference: [You Might Not Need an Effect](https://react.dev/learn/you-might-not-need-an-effect#updating-state-based-on-props-or-state)
