---
title: Configure Link Prefetching Appropriately
impact: MEDIUM-HIGH
impactDescription: instant navigation for likely destinations
tags: route, prefetching, link, navigation
---

## Configure Link Prefetching Appropriately

Next.js automatically prefetches linked routes. Control this behavior based on route importance and user likelihood to navigate.

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
