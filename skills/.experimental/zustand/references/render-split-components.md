---
title: Split Components to Minimize Subscription Scope
impact: HIGH
impactDescription: reduces re-render scope by 5-10x
tags: render, components, splitting, isolation
---

## Split Components to Minimize Subscription Scope

Extract store-subscribed code into smaller components. This isolates re-renders to only the components that need the updated state, leaving siblings and parents unaffected.

**Incorrect (large component subscribes to multiple state slices):**

```typescript
function ProductPage() {
  // All subscriptions in one component
  const product = useProductStore((s) => s.currentProduct)
  const reviews = useProductStore((s) => s.reviews)
  const relatedProducts = useProductStore((s) => s.relatedProducts)
  const cartCount = useCartStore((s) => s.items.length)

  // Entire page re-renders when any of these change
  return (
    <div className="product-page">
      <Header cartCount={cartCount} />
      <ProductDetails product={product} />
      <ReviewList reviews={reviews} />
      <RelatedProducts products={relatedProducts} />
    </div>
  )
}
```

**Correct (split into focused components):**

```typescript
function CartBadge() {
  const cartCount = useCartStore((s) => s.items.length)
  return <span className="cart-badge">{cartCount}</span>
}

function ProductDetails() {
  const product = useProductStore((s) => s.currentProduct)
  return <div className="product-details">{/* ... */}</div>
}

function ReviewList() {
  const reviews = useProductStore((s) => s.reviews)
  return <div className="reviews">{/* ... */}</div>
}

function RelatedProducts() {
  const relatedProducts = useProductStore((s) => s.relatedProducts)
  return <div className="related">{/* ... */}</div>
}

function ProductPage() {
  // Parent has no store subscriptions
  return (
    <div className="product-page">
      <Header badge={<CartBadge />} />
      <ProductDetails />
      <ReviewList />
      <RelatedProducts />
    </div>
  )
}
```

**Benefits:**
- Cart changes only re-render `CartBadge`
- Review changes only re-render `ReviewList`
- Parent `ProductPage` never re-renders from store updates
- Each component is easier to test and reason about

Reference: [Working with Zustand - TkDodo](https://tkdodo.eu/blog/working-with-zustand)
