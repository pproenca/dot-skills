---
title: Call `revalidateTag(tag, cacheLife)` with a profile — never invoke the old one-arg API
impact: CRITICAL
impactDescription: enables stale-while-revalidate so users see cached content while the new fetch lands in background; the old single-arg call no longer works in Next.js 16
tags: cache, revalidate-tag, cache-life-profile, swr
---

## Call `revalidateTag(tag, cacheLife)` with a profile — never invoke the old one-arg API

**Pattern intent:** Next.js 16's `revalidateTag` requires a `cacheLife` profile (`'max' | 'hours' | 'days' | 'weeks'`) as its second argument. The profile controls *how stale* served content may be while the revalidation runs in background. Calls with one argument either throw at runtime or no-op silently depending on the codepath.

### Shapes to recognize

- `revalidateTag('products')` with no second arg — the Next.js 15 API still in the codebase post-upgrade.
- A migrated codebase where some calls have profiles and others don't — inconsistent stale-while-revalidate behavior across the app.
- Workaround: a `revalidatePath` call where the author meant tag-based invalidation — coarser than needed, more cache miss.
- A Server Action that mutates and calls `revalidateTag` with no `'max'` profile when the user must see fresh data immediately — leaks stale content into the post-mutation render.
- A code review comment ("we should pick a cacheLife here") followed by the author hardcoding `revalidate: 0` instead — sidesteps the API.

The canonical resolution: `revalidateTag(tag, cacheLife)` where cacheLife is `'max'` (revalidate now), `'hours'` (stale up to 1h while revalidating), `'days'`, or `'weeks'`. Pick the profile based on how tolerable staleness is for the consumers of that tag.

Reference: [Next.js 16 Caching](https://nextjs.org/docs/app/building-your-application/caching)

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
