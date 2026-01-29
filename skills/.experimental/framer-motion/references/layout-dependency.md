---
title: Use layoutDependency to Limit Layout Measurements
impact: HIGH
impactDescription: reduces layout calculations by 90%+
tags: layout, performance, layoutDependency, FLIP
---

## Use layoutDependency to Limit Layout Measurements

By default, layout animations measure element position on every render. The `layoutDependency` prop tells Framer Motion to only recalculate layout when specific values change, dramatically reducing unnecessary DOM measurements.

**Incorrect (measures layout on every render):**

```tsx
function ProductList({ products, sortOrder }: Props) {
  return (
    <div className="grid">
      {products.map((product) => (
        <motion.div
          key={product.id}
          layout // Measures on EVERY render
          className="product-card"
        >
          <ProductCard product={product} />
        </motion.div>
      ))}
    </div>
  );
}
```

**Correct (measures only when sortOrder changes):**

```tsx
function ProductList({ products, sortOrder }: Props) {
  return (
    <div className="grid">
      {products.map((product) => (
        <motion.div
          key={product.id}
          layout
          layoutDependency={sortOrder} // Only measures when sortOrder changes
          className="product-card"
        >
          <ProductCard product={product} />
        </motion.div>
      ))}
    </div>
  );
}
```

**When to use layoutDependency:**
- Lists that reorder based on a specific trigger (sort, filter)
- Components where layout only changes with certain state values
- Performance-critical sections with many layout-animated elements

**Note:** Pass an array for multiple dependencies: `layoutDependency={[sortOrder, filterType]}`

Reference: [Framer Motion - Layout Animations](https://www.framer.com/motion/layout-animations/)
