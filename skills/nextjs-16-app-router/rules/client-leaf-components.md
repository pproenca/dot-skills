---
title: Push use client to Leaf Components
impact: MEDIUM
impactDescription: reduces hydration JS by 30-50% by keeping parent trees server-rendered
tags: client, hydration, bundle-size, component-architecture, server-components
---

## Push use client to Leaf Components

Placing 'use client' on wrapper components forces the entire subtree to become client components, even children that need no interactivity. Moving the boundary to leaf components keeps maximum code server-rendered and reduces JavaScript shipped to the browser.

**Incorrect (client boundary too high):**

```tsx
'use client'
// Entire ProductPage becomes client component including static content

import { useState } from 'react'

export function ProductPage({ product }: { product: Product }) {
  const [quantity, setQuantity] = useState(1)

  return (
    <div>
      <h1>{product.name}</h1>
      <p>{product.description}</p>
      <ProductSpecs specs={product.specs} />
      <ReviewsList reviews={product.reviews} />
      {/* Only this small section needs interactivity */}
      <div>
        <input
          type="number"
          value={quantity}
          onChange={(e) => setQuantity(Number(e.target.value))}
        />
        <button>Add to Cart</button>
      </div>
    </div>
  )
}
```

**Correct (client boundary at leaf):**

```tsx
import { QuantitySelector } from './QuantitySelector'

export function ProductPage({ product }: { product: Product }) {
  return (
    <div>
      <h1>{product.name}</h1>
      <p>{product.description}</p>
      <ProductSpecs specs={product.specs} />
      <ReviewsList reviews={product.reviews} />
      <QuantitySelector productId={product.id} />
    </div>
  )
}
```

```tsx
'use client'
// Only this small component ships as client JS

import { useState } from 'react'

export function QuantitySelector({ productId }: { productId: string }) {
  const [quantity, setQuantity] = useState(1)

  return (
    <div>
      <input
        type="number"
        value={quantity}
        onChange={(e) => setQuantity(Number(e.target.value))}
      />
      <button>Add to Cart</button>
    </div>
  )
}
```

**When NOT to use:** When the entire component tree genuinely requires client-side state or effects, a higher boundary reduces prop drilling complexity.

Reference: [Next.js Client Components](https://nextjs.org/docs/app/building-your-application/rendering/client-components#moving-client-components-down-the-tree)
