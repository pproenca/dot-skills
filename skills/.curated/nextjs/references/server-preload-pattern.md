---
title: Trigger critical data fetches at the top of the route via a `preload` call — don't wait for the descendant to mount
impact: MEDIUM-HIGH
impactDescription: starts critical fetches at route-entry time so they complete in parallel with the parent rendering; cuts the critical-path latency by the parent's render cost
tags: server, preload-pattern, fire-and-forget-fetch, early-trigger
---

## Trigger critical data fetches at the top of the route via a `preload` call — don't wait for the descendant to mount

**Pattern intent:** when a deeply-nested Server Component needs critical data, waiting until React renders that descendant means the fetch starts late. A `preload(id)` call from the route's top kicks off the fetch immediately; by the time the leaf renders and `await getX(id)`, the cached promise has resolved.

### Shapes to recognize

- A page that imports a deep `<ProductDetails>` Server Component which fetches in its body — the fetch starts only after parent renders complete.
- A layout that's responsible for auth gating but doesn't preload the data its children need — wastes the parallelism window.
- A "preload" function that uses `void getX(id)` but doesn't wrap `getX` with `cache()` — preload fires a *separate* fetch instead of seeding the cached promise.
- A workaround `Promise.all` at the page top that explicitly awaits descendant data — works but pollutes the page with concerns that belong to descendants.
- A page that does `preloadX(id); preloadY(id); preloadZ(id)` for unrelated data — preloading too much wastes server work; preload only the critical-path data.

The canonical resolution: define `preloadX = (id) => { void getX(id) }` next to a `cache()`-wrapped `getX`; call `preloadX(id)` from the route's top; let descendants `await getX(id)` and reuse the cached promise.

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
