---
title: Push the `'use client'` boundary down to the interactive leaf, not up at the route
impact: CRITICAL
impactDescription: shrinks the client bundle to only the interactive islands; reduces prop serialization across the boundary
tags: rsc, boundary-placement, leaf-client, route-client, island
---

## Push the `'use client'` boundary down to the interactive leaf, not up at the route

**Pattern intent:** the Client Component portion of the tree should be the minimum subtree that needs interactivity — not the whole page, not the whole feature, not the whole route. Everything above the boundary stays server-rendered, ships zero JS for itself, and pays no serialization cost.

### Shapes to recognize

- `'use client'` at the top of `page.tsx` / `layout.tsx` / a top-level route component, with most of the body being static markup and only one or two interactive leaves.
- A `ProductPage` Client Component receiving `{ product, reviews, related, recommendations }` — most of those exist only to render static children that don't need the client.
- A wrapper component is `'use client'` only because *one* descendant uses `useState` — the wrapper itself never needs the client (also overlaps with `cross-boundary-coherence`).
- A "layout" Client Component that toggles a sidebar — could be a static layout with a small client island for the sidebar toggle button.
- Heavy server-only data (large arrays, formatted HTML, image URLs) crossing the boundary because the boundary is too high — every byte gets serialized into the RSC payload.

The canonical resolution: keep the route/page/layout as a Server Component; extract just the interactive part into a small Client Component; pass only the IDs/strings/handlers it needs.

**Incorrect (boundary too high, serializes too much):**

```typescript
// components/ProductPage.tsx
'use client'  // Entire page is client-rendered

export function ProductPage({ product, reviews, related }) {
  const [quantity, setQuantity] = useState(1)

  return (
    <div>
      <h1>{product.name}</h1>
      <p>{product.description}</p>
      <ReviewsList reviews={reviews} />       {/* Static content */}
      <RelatedProducts products={related} />  {/* Static content */}

      {/* Only this needs client */}
      <input value={quantity} onChange={e => setQuantity(+e.target.value)} />
    </div>
  )
}
// All product data serialized across boundary
```

**Correct (boundary pushed to leaf):**

```typescript
// components/ProductPage.tsx (Server Component)
export function ProductPage({ product, reviews, related }) {
  return (
    <div>
      <h1>{product.name}</h1>
      <p>{product.description}</p>
      <ReviewsList reviews={reviews} />
      <RelatedProducts products={related} />

      <QuantitySelector productId={product.id} />
    </div>
  )
}

// components/QuantitySelector.tsx
'use client'

export function QuantitySelector({ productId }: { productId: string }) {
  const [quantity, setQuantity] = useState(1)
  return <input value={quantity} onChange={e => setQuantity(+e.target.value)} />
}
// Only productId crosses boundary - minimal serialization
```

**Rule of thumb:** Only the interactive "islands" need `'use client'`.
