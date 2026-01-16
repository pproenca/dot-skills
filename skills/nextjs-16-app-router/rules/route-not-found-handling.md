---
title: Use not-found.tsx for Proper 404 Handling
impact: MEDIUM
impactDescription: prevents SEO penalties from incorrect 500 error responses
tags: route, not-found, 404, error-handling, ux
---

## Use not-found.tsx for Proper 404 Handling

Use `not-found.tsx` files and the `notFound()` function to handle missing resources gracefully. This returns proper 404 HTTP status codes for SEO, provides user-friendly error pages, and can be customized per route segment.

**Incorrect (throwing errors or redirecting on missing data):**

```tsx
// app/products/[slug]/page.tsx
export default async function ProductPage({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params
  const product = await fetchProduct(slug)

  if (!product) {
    throw new Error('Product not found')  // Returns 500, not 404
  }

  return <ProductDetails product={product} />
}
// Search engines see 500 error, bad for SEO and user experience
```

**Correct (notFound() returns proper 404):**

```tsx
import { notFound } from 'next/navigation'

// app/products/[slug]/page.tsx
export default async function ProductPage({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params
  const product = await fetchProduct(slug)

  if (!product) {
    notFound()  // Returns 404 status, renders not-found.tsx
  }

  return <ProductDetails product={product} />
}
```

```tsx
// app/products/[slug]/not-found.tsx
export default function ProductNotFound() {
  return (
    <div className="not-found">
      <h1>Product Not Found</h1>
      <p>The product you're looking for doesn't exist or has been removed.</p>
      <Link href="/products">Browse all products</Link>
    </div>
  )
}
// Context-specific 404 page with relevant navigation
```

**Root-level not-found for global fallback:**

```tsx
// app/not-found.tsx
import Link from 'next/link'

export default function GlobalNotFound() {
  return (
    <div className="not-found">
      <h1>Page Not Found</h1>
      <p>We couldn't find what you were looking for.</p>
      <Link href="/">Return home</Link>
    </div>
  )
}
// Catches all unmatched routes application-wide
```

**With metadata for SEO:**

```tsx
// app/not-found.tsx
import { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'Page Not Found',
  robots: { index: false },  // Don't index 404 pages
}

export default function GlobalNotFound() {
  return (
    <div className="not-found">
      <h1>404 - Page Not Found</h1>
      <p>This page doesn't exist.</p>
    </div>
  )
}
```

**Segment-specific not-found pages:**

```text
app/
├── not-found.tsx                    # Global fallback
├── products/
│   └── [slug]/
│       └── not-found.tsx            # Product-specific 404
├── users/
│   └── [id]/
│       └── not-found.tsx            # User-specific 404
└── blog/
    └── [slug]/
        └── not-found.tsx            # Article-specific 404
```

Reference: [not-found.js](https://nextjs.org/docs/app/api-reference/file-conventions/not-found)
