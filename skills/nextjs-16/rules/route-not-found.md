---
title: Use notFound() for Missing Resources
impact: MEDIUM
impactDescription: Returns proper 404 status for SEO; prevents undefined errors and provides consistent user experience
tags: route, notFound, 404, error-handling
---

## Use notFound() for Missing Resources

Call `notFound()` when a requested resource doesn't exist. This returns a 404 status code (important for SEO) and renders your custom not-found UI. Without it, pages might show undefined errors or misleading content.

**Incorrect (no 404 handling):**

```typescript
// ❌ Crashes if product doesn't exist
export default async function ProductPage({
  params,
}: {
  params: Promise<{ id: string }>
}) {
  const { id } = await params
  const product = await getProduct(id)

  // product might be null/undefined
  return <h1>{product.name}</h1>  // Error: Cannot read 'name' of null
}
```

```typescript
// ❌ Shows confusing empty state instead of 404
export default async function ProductPage({
  params,
}: {
  params: Promise<{ id: string }>
}) {
  const { id } = await params
  const product = await getProduct(id)

  if (!product) {
    return <div>Product not found</div>  // Returns 200, bad for SEO
  }

  return <h1>{product.name}</h1>
}
```

**Correct (proper 404):**

```typescript
import { notFound } from 'next/navigation'

export default async function ProductPage({
  params,
}: {
  params: Promise<{ id: string }>
}) {
  const { id } = await params
  const product = await getProduct(id)

  if (!product) {
    notFound()  // Returns 404 status, renders not-found.tsx
  }

  return <h1>{product.name}</h1>
}
```

**Custom not-found page:**

```typescript
// app/not-found.tsx - Global 404 page
import Link from 'next/link'

export default function NotFound() {
  return (
    <div className="flex flex-col items-center justify-center min-h-screen">
      <h1 className="text-4xl font-bold">404</h1>
      <p className="text-gray-600">Page not found</p>
      <Link href="/" className="mt-4 text-blue-600 hover:underline">
        Go home
      </Link>
    </div>
  )
}
```

**Segment-specific not-found:**

```
app/
  not-found.tsx           # Global fallback
  products/
    not-found.tsx         # Products-specific 404
    [id]/
      page.tsx
```

```typescript
// app/products/not-found.tsx
import Link from 'next/link'

export default function ProductNotFound() {
  return (
    <div>
      <h1>Product not found</h1>
      <p>The product you're looking for doesn't exist.</p>
      <Link href="/products">Browse all products</Link>
    </div>
  )
}
```

**With generateStaticParams:**

```typescript
export async function generateStaticParams() {
  const products = await getAllProducts()
  return products.map(p => ({ id: p.id }))
}

// Allow requests for IDs not in generateStaticParams
export const dynamicParams = true  // Default

// Or return 404 for unknown IDs
// export const dynamicParams = false
```

**When NOT to use notFound():**
- Resource temporarily unavailable (show retry UI)
- User not authorized (redirect to login)
- Empty search results (show empty state)

Reference: [Next.js notFound](https://nextjs.org/docs/app/api-reference/functions/not-found)
