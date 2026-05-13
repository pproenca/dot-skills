---
title: A missing dynamic resource calls `notFound()` to produce a real HTTP 404 — never returns "not found" inline JSX with a 200 status
impact: MEDIUM
impactDescription: produces proper 404 HTTP status code (right for SEO crawlers and analytics); renders the closest `not-found.tsx`; standardizes the "missing" experience across routes
tags: route, not-found, 404-status, missing-resource
---

## A missing dynamic resource calls `notFound()` to produce a real HTTP 404 — never returns "not found" inline JSX with a 200 status

**Pattern intent:** when a dynamic route's resource doesn't exist (e.g., `/products/[id]` for an id that's not in the DB), the response should be HTTP 404. Returning a "Not found" string inline in the page body returns HTTP 200, which confuses SEO crawlers, analytics, and link-checking tools.

### Shapes to recognize

- `if (!product) return <div>Not found</div>` — the canonical anti-pattern.
- `if (!product) return null` — even worse; user sees a blank page and SEO sees a "valid" empty page.
- `if (!product) redirect('/products')` — silently redirects away; user can't tell what happened; loses the canonical 404 signal.
- A custom `<NotFound>` component imported and rendered conditionally — same problem; HTTP status is still 200.
- A `try/catch` that catches the missing-resource case and renders fallback JSX — the catch can be valid for other errors, but missing-resource should specifically be `notFound()`.

The canonical resolution: `import { notFound } from 'next/navigation'; if (!resource) notFound();` — throws, framework catches, renders the closest `not-found.tsx`, returns HTTP 404. Per-route `not-found.tsx` files customize the UX.

**Incorrect (rendering empty state for missing data):**

```typescript
// app/product/[id]/page.tsx
export default async function ProductPage({ params }: { params: { id: string } }) {
  const product = await getProduct(params.id)

  if (!product) {
    return <div>Product not found</div>  // Returns 200, bad for SEO
  }

  return <ProductDetail product={product} />
}
```

**Correct (using notFound()):**

```typescript
// app/product/[id]/page.tsx
import { notFound } from 'next/navigation'

export default async function ProductPage({ params }: { params: { id: string } }) {
  const product = await getProduct(params.id)

  if (!product) {
    notFound()  // Returns 404, renders not-found.tsx
  }

  return <ProductDetail product={product} />
}

// app/product/[id]/not-found.tsx
export default function ProductNotFound() {
  return (
    <div>
      <h2>Product Not Found</h2>
      <p>The product you're looking for doesn't exist.</p>
      <Link href="/products">Browse all products</Link>
    </div>
  )
}
```

**Benefits:**
- Correct 404 HTTP status for SEO
- Crawlers understand the page doesn't exist
- Custom UI for missing resources
- Can be nested per route segment
