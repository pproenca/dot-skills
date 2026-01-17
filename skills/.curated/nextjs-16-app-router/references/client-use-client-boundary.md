---
title: Minimize 'use client' Boundary Scope
impact: LOW-MEDIUM
impactDescription: reduces client JS, better performance
tags: client, use-client, boundary, hydration
---

## Minimize 'use client' Boundary Scope

Keep `'use client'` boundaries as small as possible. Only the interactive parts need to be Client Components.

**Incorrect (entire page as Client Component):**

```typescript
'use client'

export default function ProductPage({ product }) {
  const [quantity, setQuantity] = useState(1)

  return (
    <div>
      <h1>{product.name}</h1>
      <p>{product.description}</p>  {/* Static, doesn't need client */}
      <img src={product.image} />   {/* Static, doesn't need client */}
      <Reviews reviews={product.reviews} />  {/* Static, doesn't need client */}

      {/* Only this needs interactivity */}
      <input value={quantity} onChange={e => setQuantity(+e.target.value)} />
      <button onClick={() => addToCart(product.id, quantity)}>Add to Cart</button>
    </div>
  )
}
// Entire page hydrates on client
```

**Correct (minimal Client Component):**

```typescript
// app/product/[id]/page.tsx (Server Component)
export default async function ProductPage({ params }) {
  const product = await getProduct(params.id)

  return (
    <div>
      <h1>{product.name}</h1>
      <p>{product.description}</p>
      <img src={product.image} />
      <Reviews reviews={product.reviews} />

      {/* Only interactive part is client */}
      <AddToCartButton productId={product.id} />
    </div>
  )
}

// components/AddToCartButton.tsx
'use client'

import { useState } from 'react'

export function AddToCartButton({ productId }: { productId: string }) {
  const [quantity, setQuantity] = useState(1)

  return (
    <div>
      <input value={quantity} onChange={e => setQuantity(+e.target.value)} />
      <button onClick={() => addToCart(productId, quantity)}>Add to Cart</button>
    </div>
  )
}
// Only button hydrates, rest is static HTML
```
