---
title: Keep Components Server-Side by Default
impact: HIGH
impactDescription: Server Components ship 0KB JavaScript to client; average page converts 60-80% of components to zero-JS
tags: server, server-components, default, architecture
---

## Keep Components Server-Side by Default

Every component in the App Router is a Server Component by default. This means zero JavaScript sent to the client unless you explicitly add `'use client'`. Design your component tree to maximize server rendering.

**Incorrect (unnecessary client boundaries):**

```typescript
'use client'  // Why?

export default function ProductCard({ product }) {
  // No interactivity, no hooks, no browser APIs
  // Yet this ships React runtime + component code
  return (
    <div>
      <h2>{product.name}</h2>
      <p>{product.description}</p>
      <span>${product.price}</span>
    </div>
  )
}
```

**Correct (server by default):**

```typescript
// No directive = Server Component
// Zero JavaScript shipped
export default function ProductCard({ product }) {
  return (
    <div>
      <h2>{product.name}</h2>
      <p>{product.description}</p>
      <span>${product.price}</span>
    </div>
  )
}
```

**Pattern: Composition with client islands:**

```typescript
// Server Component with client interactivity island
export default function ProductCard({ product }) {
  return (
    <div>
      <h2>{product.name}</h2>
      <p>{product.description}</p>
      <span>${product.price}</span>
      {/* Only the button is client-side */}
      <AddToCartButton productId={product.id} />
    </div>
  )
}
```

```typescript
// components/AddToCartButton.tsx
'use client'

import { useCart } from '@/hooks/useCart'

export default function AddToCartButton({ productId }: { productId: string }) {
  const { addItem } = useCart()

  return (
    <button onClick={() => addItem(productId)}>
      Add to Cart
    </button>
  )
}
```

**When to use 'use client':**
- useState, useReducer, useEffect, useContext
- Event handlers (onClick, onChange, etc.)
- Browser-only APIs (localStorage, window, etc.)
- Class components

**When NOT to add 'use client':**
- Data display without interactivity
- Layout components
- Static content
- Components that only format/display props

Reference: [Next.js Server Components](https://nextjs.org/docs/app/building-your-application/rendering/server-components)
