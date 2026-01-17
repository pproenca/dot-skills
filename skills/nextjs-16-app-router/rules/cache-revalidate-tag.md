---
title: Use revalidateTag with cacheLife Profiles
impact: CRITICAL
impactDescription: stale-while-revalidate behavior, instant updates
tags: cache, revalidate-tag, cache-life, invalidation
---

## Use revalidateTag with cacheLife Profiles

Next.js 16 requires a `cacheLife` profile as the second argument to `revalidateTag`, enabling stale-while-revalidate behavior where users see cached content immediately while revalidation happens in the background.

**Incorrect (old revalidateTag API):**

```typescript
// app/actions.ts
'use server'

import { revalidateTag } from 'next/cache'

export async function updateProduct(id: string, data: FormData) {
  await db.products.update({ where: { id }, data })

  // Old API - no longer works in Next.js 16
  revalidateTag('products')
}
```

**Correct (revalidateTag with cacheLife):**

```typescript
// app/actions.ts
'use server'

import { revalidateTag } from 'next/cache'

export async function updateProduct(id: string, data: FormData) {
  await db.products.update({ where: { id }, data })

  // New API with cacheLife profile
  revalidateTag('products', 'hours')
}

// Cache profiles: 'max', 'hours', 'days', 'weeks'
// 'max' = immediate revalidation
// 'hours' = stale for up to 1 hour during revalidation
```

**Tagging cached data:**

```typescript
// lib/data.ts
'use cache'

import { cacheTag } from 'next/cache'

export async function getProducts() {
  cacheTag('products')
  const res = await fetch('https://api.store.com/products')
  return res.json()
}
```

Reference: [Next.js 16 Caching](https://nextjs.org/docs/app/building-your-application/caching)
