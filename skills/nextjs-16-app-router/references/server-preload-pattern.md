---
title: Use Preload Pattern for Critical Data
impact: MEDIUM-HIGH
impactDescription: starts fetches earlier in render tree
tags: server, preload, data-fetching, optimization
---

## Use Preload Pattern for Critical Data

Export a `preload` function that initiates data fetching at the top of the component tree. This starts fetches earlier, reducing time to first byte.

**Incorrect (data fetch starts late in component tree):**

```typescript
// app/product/[id]/page.tsx
export default async function ProductPage({ params }: { params: { id: string } }) {
  return (
    <div>
      <Header />
      <Breadcrumbs />
      <ProductDetails id={params.id} />  {/* Fetch starts here */}
    </div>
  )
}

async function ProductDetails({ id }: { id: string }) {
  const product = await getProduct(id)  // Fetch delayed by parent render
  return <div>{product.name}</div>
}
```

**Correct (preload starts fetch immediately):**

```typescript
// lib/data.ts
import { cache } from 'react'

export const getProduct = cache(async (id: string) => {
  const res = await fetch(`/api/products/${id}`)
  return res.json()
})

export const preloadProduct = (id: string) => {
  void getProduct(id)  // Start fetch, don't await
}

// app/product/[id]/page.tsx
import { preloadProduct, getProduct } from '@/lib/data'

export default async function ProductPage({ params }: { params: { id: string } }) {
  preloadProduct(params.id)  // Start fetch immediately

  return (
    <div>
      <Header />
      <Breadcrumbs />
      <ProductDetails id={params.id} />
    </div>
  )
}

async function ProductDetails({ id }: { id: string }) {
  const product = await getProduct(id)  // Uses cached promise
  return <div>{product.name}</div>
}
```

**Note:** The `cache()` wrapper ensures the preloaded data is reused by child components.
