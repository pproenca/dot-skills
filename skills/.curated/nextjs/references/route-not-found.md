---
title: Use notFound() for Missing Resources
impact: MEDIUM
impactDescription: proper 404 handling, better SEO
tags: route, not-found, 404, error-handling
---

## Use notFound() for Missing Resources

Call `notFound()` when a dynamic resource doesn't exist. This renders the closest `not-found.tsx` and returns a proper 404 status code.

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
