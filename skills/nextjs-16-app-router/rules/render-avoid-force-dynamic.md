---
title: Avoid force-dynamic Unless Necessary
impact: MEDIUM
impactDescription: prevents unnecessary server load, each dynamic request costs 50-500ms vs cached static
tags: render, dynamic, caching, performance
---

## Avoid force-dynamic Unless Necessary

Setting `dynamic = 'force-dynamic'` disables all caching and renders every request on the server. This is rarely needed—most "dynamic" use cases can be solved with ISR, on-demand revalidation, or isolating dynamic parts with Suspense.

**Incorrect (force-dynamic for cacheable content):**

```typescript
// app/products/page.tsx
export const dynamic = 'force-dynamic'  // Every request hits the server

export default async function ProductsPage() {
  const products = await fetchProducts()
  // Products only change when inventory updates, not per-request
  return <ProductGrid products={products} />
}
```

**Correct (ISR with on-demand revalidation):**

```typescript
// app/products/page.tsx
export const revalidate = 300  // Cache for 5 minutes

export default async function ProductsPage() {
  const products = await fetchProducts()
  return <ProductGrid products={products} />
}

// app/api/revalidate/route.ts - trigger when inventory changes
import { revalidatePath } from 'next/cache'

export async function POST() {
  revalidatePath('/products')
  return Response.json({ revalidated: true })
}
```

**When force-dynamic is appropriate:**

```typescript
// Real-time stock trading data that must never be stale
export const dynamic = 'force-dynamic'

export default async function LiveTicker() {
  const prices = await fetchLiveStockPrices()
  return <StockTicker prices={prices} />
}
```

**Alternative: Isolate dynamic parts with Suspense:**

```typescript
// Static shell + dynamic user section
export default function ProductsPage() {
  return (
    <>
      <StaticProductGrid />
      <Suspense fallback={<CartSkeleton />}>
        <UserCart />  {/* Only this part is dynamic */}
      </Suspense>
    </>
  )
}
```

Reference: [Dynamic Rendering](https://nextjs.org/docs/app/building-your-application/rendering/server-components#dynamic-rendering)
