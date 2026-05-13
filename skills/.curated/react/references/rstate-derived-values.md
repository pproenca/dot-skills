---
title: Compute derived values in the render body — never mirror them into separate state
impact: MEDIUM
impactDescription: eliminates a class of "derived state drift" bugs and the effects that cause them; one less state cell to keep synced
tags: rstate, derived-value, render-time-compute, no-mirror-state
---

## Compute derived values in the render body — never mirror them into separate state

**Pattern intent:** if a value can be computed from existing state, props, or context during render, that's where it should be computed. Storing it in a separate `useState` cell creates a second source of truth that drifts the moment either input changes outside the syncing path.

### Shapes to recognize (related to [`effect-avoid-unnecessary.md`](effect-avoid-unnecessary.md) — that rule lists the taxonomy of bad uses for `useEffect`; this rule is the *detection lens* for one specific case)

- `useState(initialFromProp)` + `useEffect(() => setX(prop), [prop])` — the classic "mirror a prop into state" anti-shape.
- `useState` + `useEffect` that recomputes a filtered/sorted/derived list when the source list or filter changes.
- A `useReducer` with a `RECOMPUTE_DERIVED` action or `SET_FILTERED` action — derived state with extra ceremony; the reducer is being used as an effect.
- A custom hook returning `{ filteredItems, sortedItems }` whose implementation is `useState` + `useEffect` against the input array — wrapping the anti-pattern in a hook doesn't fix it.
- A `useMemo` that depends on `useState` for storage instead of returning the value directly — re-implements memoization on top of the bug.
- Multiple `useState` cells initialized from the *same* prop (e.g., `firstName`, `lastName`) and a `useEffect` to re-sync them when the prop changes — derived state per field, multiplied.

The canonical resolution: compute `const filtered = items.filter(f)` in render. If the computation is expensive enough to matter (profile first), wrap with `useMemo`. The state cell goes away; the effect goes away; the bug goes away.

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

### In disguise — `useReducer` with a `RECOMPUTE_DERIVED` action

The grep-friendly anti-pattern is `useState` + `useEffect(() => setX(derive(a, b)), [a, b])`. The same anti-pattern *also* shows up wearing reducer clothing: a reducer that, on every action, recomputes a derived field and stores it back into state. The derived state is still in a separate cell; the effect is still implicit (the dispatcher calls); the bug is the same.

**Incorrect — in disguise (reducer storing derived state):**

```typescript
type CartState = {
  items: Item[]
  total: number        // ❌ derived from items
  itemCount: number    // ❌ derived from items
}

type CartAction =
  | { type: 'ADD'; item: Item }
  | { type: 'REMOVE'; id: string }

function cartReducer(state: CartState, action: CartAction): CartState {
  switch (action.type) {
    case 'ADD': {
      const items = [...state.items, action.item]
      return {
        items,
        total: items.reduce((sum, i) => sum + i.price, 0),     // recomputed
        itemCount: items.length,                                // recomputed
      }
    }
    case 'REMOVE': {
      const items = state.items.filter((i) => i.id !== action.id)
      return {
        items,
        total: items.reduce((sum, i) => sum + i.price, 0),
        itemCount: items.length,
      }
    }
  }
}
// Every action must remember to recompute total and itemCount.
// Add a new action that forgets and the bug ships.
```

**Correct — derived values stay in render:**

```typescript
type CartState = { items: Item[] }

type CartAction =
  | { type: 'ADD'; item: Item }
  | { type: 'REMOVE'; id: string }

function cartReducer(state: CartState, action: CartAction): CartState {
  switch (action.type) {
    case 'ADD': return { items: [...state.items, action.item] }
    case 'REMOVE': return { items: state.items.filter((i) => i.id !== action.id) }
  }
}

function ShoppingCart() {
  const [state, dispatch] = useReducer(cartReducer, { items: [] })
  // Derived where they're used; no extra state cells to keep in sync.
  const total = state.items.reduce((sum, i) => sum + i.price, 0)
  const itemCount = state.items.length
  // ...
}
```

Reference: [You Might Not Need an Effect](https://react.dev/learn/you-might-not-need-an-effect)
