---
title: Tune `<Link prefetch>` to traffic likelihood — disable on low-traffic links, prefetch-on-hover for conditional routes
impact: MEDIUM-HIGH
impactDescription: prefetch where it matters (likely navigation = instant) and disable where it doesn't (low-likelihood links waste bandwidth)
tags: route, link-prefetch, on-hover-prefetch, bandwidth
---

## Tune `<Link prefetch>` to traffic likelihood — disable on low-traffic links, prefetch-on-hover for conditional routes

**Pattern intent:** Next.js prefetches every `<Link>` in viewport by default. That's right for high-traffic links (primary nav) but wasteful for low-traffic ones (footer terms, admin settings, legal pages). Make the decision per-link.

### Shapes to recognize

- A footer with 20+ `<Link>` elements all default-prefetched — every page load prefetches the same 20 routes the user almost never visits.
- A nav with `<Link prefetch={false}>` everywhere "to save bandwidth" — defeats the optimization for primary routes.
- Product cards rendered in a list, each with a default-prefetched `<Link>` to the detail page — prefetches *all* product pages on every list view.
- A `router.prefetch(...)` call in a `useEffect` that fires for every item in a list — same blast as above, manually.
- A workaround `setTimeout(() => router.prefetch(...), 1000)` to "delay" prefetching — fragile; use `prefetch={false}` + hover prefetch instead.

The canonical resolution: primary navigation stays default-prefetched. Long lists, low-traffic links, and admin/legal pages get `prefetch={false}`. For conditional routes (product cards in a list), trigger `router.prefetch(path)` on hover/focus to prefetch only when the user signals intent.

**Incorrect (no prefetch consideration):**

```typescript
// Prefetches all links, including rarely used ones
export default function Navigation() {
  return (
    <nav>
      <Link href="/">Home</Link>
      <Link href="/products">Products</Link>
      <Link href="/admin/settings">Settings</Link>  {/* Rarely accessed */}
      <Link href="/terms">Terms</Link>  {/* Rarely accessed */}
    </nav>
  )
}
// Wastes bandwidth prefetching unlikely routes
```

**Correct (strategic prefetching):**

```typescript
export default function Navigation() {
  return (
    <nav>
      {/* High-traffic routes - prefetch (default) */}
      <Link href="/">Home</Link>
      <Link href="/products">Products</Link>

      {/* Low-traffic routes - disable prefetch */}
      <Link href="/admin/settings" prefetch={false}>Settings</Link>
      <Link href="/terms" prefetch={false}>Terms</Link>
    </nav>
  )
}
```

**Prefetch on hover for conditional routes:**

```typescript
'use client'

import { useRouter } from 'next/navigation'

export function ProductCard({ product }) {
  const router = useRouter()

  return (
    <div
      onMouseEnter={() => router.prefetch(`/product/${product.id}`)}
      onClick={() => router.push(`/product/${product.id}`)}
    >
      {product.name}
    </div>
  )
}
// Prefetches only when user shows intent
```

**Note:** In production, prefetching only loads the shared layout and static portions of the route.
