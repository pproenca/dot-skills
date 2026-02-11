---
title: Derive Values Instead of Syncing State
impact: CRITICAL
impactDescription: eliminates double-render cycle, prevents sync drift
tags: state, derived-state, useEffect, sync-bugs
---

## Derive Values Instead of Syncing State

Using useEffect to compute a derived value from other state causes a double-render: first the source state updates and renders, then the effect fires, updates the derived state, and renders again. Computing the value during render eliminates the extra cycle and makes it impossible for source and derived values to drift out of sync.

**Incorrect (useEffect sync — double render + sync drift risk):**

```tsx
function ProductCatalog({ products, categoryFilter, priceRange }: ProductCatalogProps) {
  const [filteredProducts, setFilteredProducts] = useState<Product[]>([]);
  const [totalPrice, setTotalPrice] = useState(0);

  // First render: stale filteredProducts. Second render: correct filteredProducts.
  useEffect(() => {
    const filtered = products.filter(
      (p) => p.category === categoryFilter && p.price >= priceRange.min && p.price <= priceRange.max
    );
    setFilteredProducts(filtered);
  }, [products, categoryFilter, priceRange]);

  // Third render: correct totalPrice. User sees flicker.
  useEffect(() => {
    const total = filteredProducts.reduce((sum, p) => sum + p.price, 0);
    setTotalPrice(total);
  }, [filteredProducts]);

  return (
    <div>
      <p>Total: {formatCurrency(totalPrice)}</p>
      {filteredProducts.map((p) => <ProductCard key={p.id} product={p} />)}
    </div>
  );
}
```

**Correct (derive during render — single pass, always in sync):**

```tsx
function ProductCatalog({ products, categoryFilter, priceRange }: ProductCatalogProps) {
  // Computed every render — always consistent with source data
  const filteredProducts = products.filter(
    (p) => p.category === categoryFilter && p.price >= priceRange.min && p.price <= priceRange.max
  );

  const totalPrice = filteredProducts.reduce((sum, p) => sum + p.price, 0);

  return (
    <div>
      <p>Total: {formatCurrency(totalPrice)}</p>
      {filteredProducts.map((p) => <ProductCard key={p.id} product={p} />)}
    </div>
  );
}
```

Reference: [React Docs - You Might Not Need an Effect](https://react.dev/learn/you-might-not-need-an-effect)
