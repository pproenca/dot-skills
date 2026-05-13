---
title: Wrap expensive pure components in `memo()` only when their props are actually stable
impact: MEDIUM
impactDescription: 5-50ms savings per unchanged render of an expensive child when its props don't change
tags: memo, react-memo, expensive-child, stable-props
---

## Wrap expensive pure components in `memo()` only when their props are actually stable

**Pattern intent:** `memo` lets an expensive child skip render when its props are reference-equal to last time. The skip pays off only when the props *actually stay stable*. Memo-without-stable-props is dead code; stable-props-without-memo passes up the savings.

### Shapes to recognize

- A `memo`-wrapped child that receives an inline object/array literal from the parent (`<Child options={{ ... }} />`) — every parent render makes a new object, memo never skips.
- A `memo`-wrapped child that receives an inline arrow function as a callback prop (`<Child onClick={() => doX()} />`) — same problem, same outcome.
- A `memo`-wrapped child that receives a non-stable spread `<Child {...rest}>` from a parent that built `rest` inline — opaque, still unstable.
- A `memo` wrapping a leaf that renders three plain strings — render is cheap; the memo overhead exceeds the savings.
- Custom `arePropsEqual` second-argument doing deep object equality — usually wrong; the cost of comparing exceeds the savings of skipping, and you risk bugs when nested mutation slips by.

The canonical resolution: profile first; reach for `memo` when the child is expensive *and* its props naturally stay reference-equal (typed once at the top, passed through). If you control the parent, prefer stabilizing the props (via `useMemo`/`useCallback` or React Compiler) over `memo` with a custom comparator. With React Compiler v1.0, most of this is handled automatically.

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

**Note:** If using [React Compiler v1.0+](https://react.dev/blog/2025/10/07/react-compiler-1) (works with React 17+), React.memo is handled automatically. Use manual memo only when the compiler can't optimize your case. Ensure props passed to memo'd components are stable (primitives, memoized objects/functions).
