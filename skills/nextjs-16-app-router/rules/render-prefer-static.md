---
title: Default to Static Rendering
impact: MEDIUM
impactDescription: enables edge caching and reduces TTFB by 50-200ms per request
tags: render, static, caching, performance
---

## Default to Static Rendering

Static rendering generates HTML at build time, allowing responses to be cached at the edge and served instantly. Dynamic rendering should be an explicit opt-in only when you need request-specific data like cookies, headers, or search params.

**Incorrect (unnecessary dynamic rendering):**

```typescript
// app/products/[slug]/page.tsx
import { headers } from 'next/headers'

export default async function ProductPage({
  params,
}: {
  params: Promise<{ slug: string }>
}) {
  const { slug } = await params
  // Calling headers() makes entire route dynamic even if not needed
  const headersList = await headers()
  const product = await fetchProduct(slug)

  return <ProductDetails product={product} />
}
```

**Correct (static by default):**

```typescript
// app/products/[slug]/page.tsx
export default async function ProductPage({
  params,
}: {
  params: Promise<{ slug: string }>
}) {
  const { slug } = await params
  const product = await fetchProduct(slug)

  return <ProductDetails product={product} />
}

// Explicitly generate static pages at build time
export async function generateStaticParams() {
  const products = await fetchAllProducts()
  return products.map((product) => ({ slug: product.slug }))
}
```

**When dynamic rendering is appropriate:**

- User-specific content (cookies for auth, preferences)
- Real-time data that cannot be stale (stock prices, inventory)
- Search results based on query parameters

Reference: [Static and Dynamic Rendering](https://nextjs.org/docs/app/building-your-application/rendering/server-components#static-rendering-default)
