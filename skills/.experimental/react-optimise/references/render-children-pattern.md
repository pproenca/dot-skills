---
title: Use Children Pattern to Prevent Parent Re-Renders
impact: HIGH
impactDescription: eliminates re-renders of static subtrees during parent state changes
tags: render, children-pattern, composition, re-renders
---

## Use Children Pattern to Prevent Parent Re-Renders

When a parent component owns state that changes frequently, all JSX declared inside that parent re-renders on every state change. Moving expensive children above the state-owning component and passing them as `children` props preserves their identity across renders, skipping reconciliation entirely.

**Incorrect (expensive subtree re-renders on every mouse move):**

```tsx
function ProductPage() {
  const [mousePosition, setMousePosition] = useState({ x: 0, y: 0 })

  return (
    <div onMouseMove={(e) => setMousePosition({ x: e.clientX, y: e.clientY })}>
      <Cursor position={mousePosition} />
      <ProductGallery />   {/* re-renders on every mouse move */}
      <ProductReviews />   {/* re-renders on every mouse move */}
      <RelatedProducts />  {/* re-renders on every mouse move */}
    </div>
  )
}
```

**Correct (children identity preserved, no re-renders):**

```tsx
function MouseTracker({ children }: { children: ReactNode }) {
  const [mousePosition, setMousePosition] = useState({ x: 0, y: 0 })

  return (
    <div onMouseMove={(e) => setMousePosition({ x: e.clientX, y: e.clientY })}>
      <Cursor position={mousePosition} />
      {children} {/* same JSX reference — React skips reconciliation */}
    </div>
  )
}

function ProductPage() {
  return (
    <MouseTracker>
      <ProductGallery />
      <ProductReviews />
      <RelatedProducts />
    </MouseTracker>
  )
}
```

Reference: [Before You memo() — Dan Abramov](https://overreacted.io/before-you-memo/)
