---
title: Mark cacheable Server Components/functions explicitly with `'use cache'` — never rely on implicit caching
impact: CRITICAL
impactDescription: eliminates the "Next.js 15 cached this, Next.js 16 doesn't" silent regression; makes cache scope visible in the source
tags: cache, use-cache-directive, explicit-cache, opt-in-cache
---

## Mark cacheable Server Components/functions explicitly with `'use cache'` — never rely on implicit caching

**Pattern intent:** Next.js 16 removed default fetch caching. Data that should be cached must opt in, either via the `'use cache'` directive on a Server Component / async function or via `unstable_cache` around a fetcher. Pages relying on Next.js 15's implicit caching silently re-fetch on every request and hammer upstream APIs.

### Shapes to recognize

- A Server Component making `fetch(url)` calls that worked fine in Next.js 15 — and silently became per-request in Next.js 16.
- Migration from 15→16 where p95 latency suddenly doubled — implicit cache loss, not "the server got slow."
- A `fetch(...)` without any cache option, where the data clearly doesn't need to be per-request — `'use cache'` (or `unstable_cache`) was forgotten.
- A custom hand-rolled cache (module-level `Map`, in-memory dictionary) used to "fix" the per-request fetching — reinvents the wheel, doesn't integrate with `revalidateTag`.
- A Server Component with manual `revalidate: 3600` on every fetch but no top-level `'use cache'` — works but is finer-grained than needed; `'use cache'` on the whole component is often cleaner.
- A whole route marked `force-static` to "cache it all" — works but loses granular invalidation; `'use cache'` + `cacheTag` is more flexible.

The canonical resolution: add `'use cache'` to the top of the Server Component or async function whose results should be cached. Pair with `cacheTag(...)` for invalidation. Use `unstable_cache(fn, key, options)` for finer-grained control.

Reference: [Next.js 16 Cache Components](https://nextjs.org/blog/next-16)

**Incorrect (relying on implicit caching):**

```typescript
// app/products/page.tsx
export default async function ProductsPage() {
  // In Next.js 15, this was cached by default
  // In Next.js 16, this fetches fresh data every request
  const products = await fetch('https://api.store.com/products')

  return <ProductList products={products} />
}
```

**Correct (explicit caching with 'use cache'):**

```typescript
// app/products/page.tsx
'use cache'

export default async function ProductsPage() {
  const products = await fetch('https://api.store.com/products')

  return <ProductList products={products} />
}
// Entire page is cached until manually invalidated
```

**Alternative (cache specific functions):**

```typescript
// lib/data.ts
import { unstable_cache } from 'next/cache'

export const getProducts = unstable_cache(
  async () => {
    const res = await fetch('https://api.store.com/products')
    return res.json()
  },
  ['products'],
  { revalidate: 3600 }  // Cache for 1 hour
)
```

---

### In disguise — a hand-rolled module-level cache mimicking `'use cache'`

The grep-friendly anti-pattern is a `fetch(...)` with no cache annotation in a Server Component. The disguise is a *custom* caching layer (module-level `Map`, in-memory dictionary, ad-hoc TTL) introduced "to fix" the per-request fetching. It works for one request lifecycle but doesn't integrate with `revalidateTag`, can't survive a server restart cleanly, and competes with the platform's caching primitive.

**Incorrect — in disguise (hand-rolled cache layer):**

```typescript
// lib/cache.ts — homemade caching
const productsCache = new Map<string, { data: Product[]; expires: number }>()

export async function getProducts(category: string): Promise<Product[]> {
  const cached = productsCache.get(category)
  if (cached && cached.expires > Date.now()) return cached.data

  const res = await fetch(`https://api.store.com/products?category=${category}`)
  const data = await res.json()
  productsCache.set(category, { data, expires: Date.now() + 1000 * 60 * 5 })
  return data
}
```

Works locally, breaks in production: no shared state across server instances, no integration with `revalidateTag('products')`, no SWR semantics. On every server restart, the cache is cold.

**Correct — `unstable_cache` with tagging:**

```typescript
// lib/products.ts
import { unstable_cache } from 'next/cache'

export const getProducts = unstable_cache(
  async (category: string) => {
    const res = await fetch(`https://api.store.com/products?category=${category}`)
    return res.json() as Promise<Product[]>
  },
  ['products-by-category'],
  { tags: ['products'], revalidate: 300 }
)
```

Now `revalidateTag('products', 'max')` invalidates across all server instances. The audit can find this and the framework knows about it.

Final reference: [Next.js 16 Cache Components](https://nextjs.org/blog/next-16)
