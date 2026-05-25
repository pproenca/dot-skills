---
title: Control cache lifetime and invalidation with cacheLife and cacheTag
tags: cache, use-cache, cachelife, cachetag
---

## Control cache lifetime and invalidation with cacheLife and cacheTag

The model controls revalidation with `export const revalidate = 3600` or `fetch(..., { next: { revalidate, tags } })`. Inside a `'use cache'` scope those don't apply. Use `cacheLife(profile)` for the TTL and `cacheTag(tag)` for on-demand invalidation, both called inside the cached function. Without `cacheLife` the `default` profile applies (≈5 min client stale, 15 min server revalidate, no time-based expiry) — frequently staler or fresher than you intend, so set it explicitly.

```tsx
import { cacheLife, cacheTag } from 'next/cache'

async function getBlogPosts() {
  'use cache'
  cacheLife('hours') // built-in profile (also: 'minutes', 'days', 'max', or custom)
  cacheTag('posts') // lets a Server Action invalidate this entry by tag later
  const res = await fetch('https://api.acme.com/posts')
  return res.json()
}
```

Reference: [use cache — revalidation](https://nextjs.org/docs/app/api-reference/directives/use-cache#revalidation)
