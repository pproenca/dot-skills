---
title: Use revalidatePath and revalidateTag for On-Demand Revalidation
impact: HIGH
impactDescription: ensures instant cache updates after mutations, eliminates stale data without sacrificing cache benefits
tags: cache, revalidatePath, revalidateTag, server-actions, mutations
---

## Use revalidatePath and revalidateTag for On-Demand Revalidation

Time-based revalidation alone causes stale data after mutations. When a user updates a product, they expect to see changes immediately - not after the revalidation window expires. On-demand revalidation invalidates specific cache entries the moment data changes.

**Incorrect (no revalidation after mutation):**

```typescript
// app/actions/products.ts
'use server'

import { db } from '@/lib/db'

export async function updateProduct(productId: string, formData: FormData) {
  const name = formData.get('name') as string
  const price = parseFloat(formData.get('price') as string)

  await db.product.update({
    where: { id: productId },
    data: { name, price },
  })
  // Cache still serves stale data until time-based revalidation triggers
  return { success: true }
}
```

**Correct (on-demand revalidation after mutation):**

```typescript
// app/actions/products.ts
'use server'

import { revalidatePath, revalidateTag } from 'next/cache'
import { db } from '@/lib/db'

export async function updateProduct(productId: string, formData: FormData) {
  const name = formData.get('name') as string
  const price = parseFloat(formData.get('price') as string)

  await db.product.update({
    where: { id: productId },
    data: { name, price },
  })

  // Invalidate specific product and product list caches
  revalidateTag(`product-${productId}`)
  revalidateTag('products')

  return { success: true }
}
```

**Choose the right revalidation method:**

```typescript
'use server'

import { revalidatePath, revalidateTag } from 'next/cache'

// revalidatePath: Invalidate all cached data for a specific route
export async function createProduct(formData: FormData) {
  await db.product.create({ data: { /* ... */ } })

  // Revalidates /products page and all its data
  revalidatePath('/products')

  // Can also revalidate dynamic routes
  revalidatePath('/products/[id]', 'page')

  // Or entire layouts
  revalidatePath('/products', 'layout')
}

// revalidateTag: Surgical invalidation of tagged data only
export async function updateProductPrice(productId: string, price: number) {
  await db.product.update({
    where: { id: productId },
    data: { price },
  })

  // Only invalidates fetch/unstable_cache calls tagged with this
  revalidateTag(`product-${productId}`)
}
```

**Tag your data sources for targeted invalidation:**

```typescript
// app/lib/products.ts
import { unstable_cache } from 'next/cache'

// Tag cache entries for surgical revalidation
export const getProductById = (productId: string) =>
  unstable_cache(
    async () => db.product.findUnique({ where: { id: productId } }),
    [`product-${productId}`],
    { tags: [`product-${productId}`, 'products'] } // Multiple tags
  )()

// Fetch with tags
export async function getProductReviews(productId: string) {
  const response = await fetch(`/api/products/${productId}/reviews`, {
    next: { tags: [`product-${productId}-reviews`, 'reviews'] },
  })
  return response.json()
}
```

**Benefits of tag-based over path-based:**

| Approach | Scope | Use When |
|----------|-------|----------|
| `revalidatePath` | All data on a route | Page structure changed, layout update |
| `revalidateTag` | Only tagged data | Specific entity updated, surgical invalidation |

Reference: [Next.js revalidatePath](https://nextjs.org/docs/app/api-reference/functions/revalidatePath) | [revalidateTag](https://nextjs.org/docs/app/api-reference/functions/revalidateTag)
