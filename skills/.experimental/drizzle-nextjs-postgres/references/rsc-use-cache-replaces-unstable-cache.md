---
title: Cache queries with use cache, not unstable_cache or route segment config
tags: rsc, use-cache, cache-life, cache-tag
---

## Cache queries with use cache, not unstable_cache or route segment config

The caching vocabulary most models reach for — `unstable_cache(fn, keyParts, { revalidate, tags })`, `export const revalidate = 3600`, `export const dynamic = 'force-static'`, `noStore()` — is the Next.js 14/15 model. Under `cacheComponents` those route segment configs are replaced by `use cache` plus `cacheLife`/`cacheTag`, and `noStore()` is redundant because nothing is cached unless you ask. Writing the old form produces code that either errors or silently behaves differently from what the author intended, and the manual `keyParts` array it carries is now derived from the function arguments automatically.

```typescript
// lib/queries/invoices.ts
import { cacheLife, cacheTag } from 'next/cache'
import { eq } from 'drizzle-orm'
import { db } from '@/lib/db'
import { invoices } from '@/lib/db/schema'

export async function getInvoice(invoiceId: number) {
  'use cache'
  cacheLife('hours')
  cacheTag(`invoice-${invoiceId}`)

  return db.query.invoices.findFirst({ where: eq(invoices.id, invoiceId) })
}
```

`invoiceId` becomes part of the cache key because it is an argument, so no key-parts array is needed. Tag the entry so the Server Action that writes the invoice can invalidate exactly this entry — see [`mut-updatetag-vs-revalidatetag`](mut-updatetag-vs-revalidatetag.md).

Reference: [Next.js — Migrating to Cache Components](https://nextjs.org/docs/app/guides/migrating-to-cache-components) · [Next.js — use cache](https://nextjs.org/docs/app/api-reference/directives/use-cache)
