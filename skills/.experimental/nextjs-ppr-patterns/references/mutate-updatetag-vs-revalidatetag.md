---
title: Pick updateTag for read-your-writes after a form mutation
tags: mutate, updatetag, revalidatetag, server-actions
---

## Pick updateTag for read-your-writes after a form mutation

After a form mutation the model calls single-argument `revalidateTag('orders')`. In Next.js 16 that form is deprecated and gives stale-while-revalidate — the user who just submitted sees the **old** data on the next render (the classic stale-form bug). Pick by intent: in a Server Action use `updateTag(tag)` for read-your-writes (expire + re-read fresh within the same request, so the user sees their change immediately); use `revalidateTag(tag, profile)` — now requiring a `cacheLife` profile like `'max'` — for background SWR of content that tolerates eventual consistency; use `refresh()` to re-fetch only *uncached* data (e.g. a header count) without touching the cache.

**Incorrect (deprecated single-arg — user sees the stale list):**

```ts
'use server'
import { revalidateTag } from 'next/cache'

export async function createOrder(data: FormData) {
  await db.order.create({ data: parseOrder(data) })
  revalidateTag('orders') // SWR: the new order isn't visible on the immediate re-render
}
```

**Correct (read-your-writes):**

```ts
'use server'
import { updateTag } from 'next/cache'

export async function createOrder(data: FormData) {
  await db.order.create({ data: parseOrder(data) })
  updateTag('orders') // the new order is visible immediately
}
```

Reference: [Next.js 16 — updateTag, revalidateTag, refresh](https://nextjs.org/blog/next-16#improved-caching-apis)
