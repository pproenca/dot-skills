---
title: Default to Server Components
impact: HIGH
impactDescription: reduces client JavaScript by 30-60%, improves TTI by eliminating hydration overhead
tags: server, rsc, bundle-size, architecture
---

## Default to Server Components

In Next.js 16 App Router, components are Server Components by default. Only add 'use client' when you need browser interactivity. Every unnecessary 'use client' directive ships component code plus its dependencies to the browser, bloating your bundle.

**Incorrect (unnecessary client directive):**

```tsx
'use client'  // Ships entire component + dependencies to browser

import { formatCurrency } from '@/lib/formatters'

export function ProductCard({ product }: { product: Product }) {
  return (
    <article className="product-card">
      <h2>{product.name}</h2>
      <p className="price">{formatCurrency(product.price)}</p>
      <p>{product.description}</p>
    </article>
  )
}
// formatCurrency library now in client bundle despite no interactivity
```

**Correct (server component by default):**

```tsx
// No directive - Server Component by default
import { formatCurrency } from '@/lib/formatters'

export function ProductCard({ product }: { product: Product }) {
  return (
    <article className="product-card">
      <h2>{product.name}</h2>
      <p className="price">{formatCurrency(product.price)}</p>
      <p>{product.description}</p>
    </article>
  )
}
// Renders on server, only HTML sent to client
```

**When 'use client' is required:**
- Using hooks (useState, useEffect, useContext, useReducer)
- Adding event handlers (onClick, onChange, onSubmit)
- Accessing browser APIs (window, document, localStorage)
- Using client-only libraries (animation libraries, date pickers)

Reference: [Server Components](https://nextjs.org/docs/app/building-your-application/rendering/server-components)
