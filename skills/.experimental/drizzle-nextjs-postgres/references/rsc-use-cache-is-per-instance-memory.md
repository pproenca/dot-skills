---
title: Do not treat use cache as durable query caching on serverless
tags: rsc, use-cache, serverless, cache-handler
---

## Do not treat use cache as durable query caching on serverless

`use cache` reads like a drop-in replacement for `unstable_cache`, so it gets applied to expensive aggregate queries to take load off Postgres — and on serverless it does not do that. Its default backing store is an in-memory LRU scoped to one instance and one deployment: entries do not survive instance teardown, are not shared between concurrently running instances, and are discarded on every deploy. A dashboard rollup wrapped in `use cache` and `cacheLife('hours')` can still hit the database on a large fraction of requests. `unstable_cache` and the `fetch` Data Cache persist across instances and deployments; `use cache` does not, and that difference is the reason to choose deliberately rather than mechanically.

```typescript
// lib/queries/revenue.ts — a genuinely expensive rollup that must not hit Postgres per request
import { cacheLife, cacheTag } from 'next/cache'

export async function getMonthlyRevenue(organizationId: number) {
  'use cache: remote' // platform-provided shared cache, survives instance teardown
  cacheLife('hours')
  cacheTag(`org-${organizationId}-revenue`)

  return db
    .select({ month: sql<string>`date_trunc('month', ${invoices.issuedAt})`, total: sum(invoices.amountCents) })
    .from(invoices)
    .where(eq(invoices.organizationId, organizationId))
    .groupBy(sql`1`)
}
```

Plain `use cache` is the right choice for what it was designed for: filling the static shell at build time and deduplicating work within a render. For cross-instance durability, either use `use cache: remote`, configure a `cacheHandlers` entry backed by Redis, or keep the aggregate in a materialized view that Postgres refreshes on a schedule.

Reference: [Next.js — Migrating to Cache Components: fetch cache options](https://nextjs.org/docs/app/guides/migrating-to-cache-components) · [Next.js — use cache: Runtime caching considerations](https://nextjs.org/docs/app/api-reference/directives/use-cache)
