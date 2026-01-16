---
title: Use Tag-Based On-Demand Revalidation
impact: MEDIUM
impactDescription: Invalidates specific cached data when it changes; eliminates stale content without sacrificing cache performance
tags: cache, revalidateTag, on-demand, webhooks
---

## Use Tag-Based On-Demand Revalidation

Tag-based revalidation lets you invalidate specific cached data when it changes, rather than waiting for time-based expiration. This keeps content fresh while maintaining cache benefits.

**Incorrect (time-based only):**

```typescript
// Product cached for 1 hour - stale if updated before that
const product = await fetch(`https://api.example.com/products/${id}`, {
  next: { revalidate: 3600 }
}).then(r => r.json())

// If product is updated at minute 5, users see stale data for 55 more minutes
```

**Correct (tagged for on-demand revalidation):**

```typescript
// app/products/[id]/page.tsx
const product = await fetch(`https://api.example.com/products/${id}`, {
  next: {
    revalidate: 86400,  // Fallback: revalidate daily
    tags: ['products', `product-${id}`]  // On-demand: invalidate immediately
  }
}).then(r => r.json())
```

```typescript
// app/api/webhooks/product-update/route.ts
import { revalidateTag } from 'next/cache'
import { NextRequest } from 'next/server'

export async function POST(request: NextRequest) {
  const secret = request.headers.get('x-webhook-secret')

  if (secret !== process.env.WEBHOOK_SECRET) {
    return new Response('Unauthorized', { status: 401 })
  }

  const { productId } = await request.json()

  // Invalidate specific product
  revalidateTag(`product-${productId}`)

  // Or invalidate all products
  // revalidateTag('products')

  return Response.json({ revalidated: true, now: Date.now() })
}
```

**Tag strategy patterns:**

```typescript
// Hierarchical tags for flexible invalidation
const product = await fetch(url, {
  next: {
    tags: [
      'products',                    // Invalidate all products
      `category-${product.category}`, // Invalidate category
      `product-${product.id}`,       // Invalidate single product
    ]
  }
})

// Invalidate by scope:
// revalidateTag('products')           → All products
// revalidateTag('category-electronics') → Electronics category
// revalidateTag('product-123')        → Single product
```

**Using with cacheTag (Next.js 16):**

```typescript
import { cacheTag, cacheLife } from 'next/cache'

async function getProduct(id: string) {
  'use cache'
  cacheLife('days')
  cacheTag('products', `product-${id}`)

  return db.query('SELECT * FROM products WHERE id = ?', [id])
}

// Revalidate after mutation
export async function updateProduct(id: string, data: ProductData) {
  'use server'

  await db.update('products', id, data)
  revalidateTag(`product-${id}`)
}
```

**Common webhook integrations:**
- CMS updates (Contentful, Sanity, Strapi)
- E-commerce inventory changes (Shopify, WooCommerce)
- Database triggers
- Admin panel actions

**When NOT to use tag-based revalidation:**
- Data changes predictably on schedule (time-based is simpler)
- No webhook/trigger mechanism available
- Real-time data where caching doesn't apply

Reference: [Next.js revalidateTag](https://nextjs.org/docs/app/api-reference/functions/revalidateTag)
