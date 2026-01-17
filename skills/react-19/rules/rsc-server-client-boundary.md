---
title: Minimize Server/Client Boundary Crossings
impact: CRITICAL
impactDescription: reduces serialization overhead, smaller bundles
tags: rsc, server-components, boundary, optimization
---

## Minimize Server/Client Boundary Crossings

Each `'use client'` boundary requires serializing props from server to client. Push boundaries as low as possible in the component tree.

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
