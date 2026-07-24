---
title: Do not move routes to the edge runtime to satisfy a driver
tags: rsc, edge-runtime, cache-components, driver
---

## Do not move routes to the edge runtime to satisfy a driver

The chain of reasoning that ends in `export const runtime = 'edge'` usually starts somewhere reasonable — an HTTP-based Postgres driver was chosen, the docs mention edge compatibility, so the route gets moved to match. In Next.js 16 that trade is unavailable: Cache Components requires the Node.js runtime, and a route exporting `runtime = 'edge'` is not supported under it. Node is already the default, and the HTTP drivers run there perfectly well, so the correct move is to delete the export rather than restructure the app around it.

```tsx
// app/api/invoices/route.ts
// export const runtime = 'edge'   ← remove; unsupported with cacheComponents

import { cacheLife } from 'next/cache'
import { db } from '@/lib/db'

export async function GET() {
  return Response.json(await getPublishedInvoices())
}

async function getPublishedInvoices() {
  'use cache'
  cacheLife('hours')
  return db.select().from(invoices).where(eq(invoices.status, 'published')).limit(100)
}
```

Note the second half of that example: with Cache Components a `GET` handler prerenders like a page, so an uncached read inside it bails out of prerendering *by throwing*. If the handler already has a `try/catch` around other work, it will swallow that bail-out and log noise during the build. If a route genuinely needs edge-level geography, use [Proxy](https://nextjs.org/docs/app/api-reference/file-conventions/proxy) for the edge concern and keep the database work in a Node route.

Reference: [Next.js — Migrating to Cache Components: `runtime = 'edge'`](https://nextjs.org/docs/app/guides/migrating-to-cache-components)
