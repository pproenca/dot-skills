---
title: Use React.memo for Expensive Pure Components
impact: MEDIUM
impactDescription: skips re-render when props unchanged
tags: memo, react-memo, performance, pure
---

## Use React.memo for Expensive Pure Components

Wrap components in memo() to skip re-renders when props are the same. Effective for expensive renders with stable props.

**Incorrect (re-renders on parent state change):**

```typescript
function ProductList({ products }: { products: Product[] }) {
  return products.map(product => (
    <ProductCard key={product.id} product={product} />
  ))
}

function ProductCard({ product }: { product: Product }) {
  // Expensive render with lots of calculations
  const rating = calculateRating(product.reviews)
  const availability = checkInventory(product.id)

  return (
    <div>
      <h3>{product.name}</h3>
      <Rating value={rating} />
      <Availability status={availability} />
    </div>
  )
}
// Every ProductCard re-renders when any parent state changes
```

**Correct (memoized component):**

```typescript
import { memo } from 'react'

const ProductCard = memo(function ProductCard({ product }: { product: Product }) {
  const rating = calculateRating(product.reviews)
  const availability = checkInventory(product.id)

  return (
    <div>
      <h3>{product.name}</h3>
      <Rating value={rating} />
      <Availability status={availability} />
    </div>
  )
})
// Only re-renders when product prop changes
```

**Custom comparison for complex props:**

```typescript
const ProductCard = memo(
  function ProductCard({ product, onClick }) {
    // ...
  },
  (prevProps, nextProps) => {
    // Return true if props are equal (skip re-render)
    return prevProps.product.id === nextProps.product.id &&
           prevProps.product.updatedAt === nextProps.product.updatedAt
  }
)
```

**Note:** Ensure props passed to memo'd components are stable (primitives, memoized objects/functions).
