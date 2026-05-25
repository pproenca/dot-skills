---
title: Mark static and cacheable work with the use cache directive
tags: cache, use-cache, directive, prerender
---

## Mark static and cacheable work with the use cache directive

To make data or UI static, the model reaches for Next.js 14/15 mechanisms — `export const revalidate`, `unstable_cache`, or `fetch(..., { next: { revalidate } })`. Under Cache Components the single mechanism is the `'use cache'` directive at the top of an async function (data-level), a component / page / layout (UI-level), or a whole file (caches every export — all must then be async). To prerender an entire route, add it to **both** the `layout` and the `page`, which are cached as separate entry points.

```tsx
// Function level — cache a query
export async function getProducts() {
  'use cache'
  return db.product.findMany()
}

// Component level — cache a component's rendered output (goes into the static shell)
export async function FeaturedProducts() {
  'use cache'
  const products = await getProducts()
  return <ProductGrid products={products} />
}
```

Reference: [use cache directive](https://nextjs.org/docs/app/api-reference/directives/use-cache)
