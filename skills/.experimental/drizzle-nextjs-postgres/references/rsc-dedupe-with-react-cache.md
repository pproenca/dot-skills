---
title: Wrap per-request lookups in React cache to dedupe across the tree
tags: rsc, react-cache, deduplication, request-scope
---

## Wrap per-request lookups in React cache to dedupe across the tree

Next.js deduplicates identical `fetch` calls within a render pass; it cannot do the same for a Drizzle query, because it has no way to know two calls are equivalent. So the standard App Router shape — a layout that loads the current user for the nav, a page that loads it for permissions, and `generateMetadata` that loads it for the title — issues the same `SELECT` three times per request. React's `cache()` memoizes on the arguments for the lifetime of one request, which is exactly the scope wanted here: shared within the render, never shared between users.

```typescript
// lib/queries/customer.ts
import { cache } from 'react'
import { eq } from 'drizzle-orm'
import { db } from '@/lib/db'
import { customers } from '@/lib/db/schema'

export const getCustomer = cache(async (customerId: number) => {
  return db.query.customers.findFirst({ where: eq(customers.id, customerId) })
})
```

Now `getCustomer(42)` in the layout, the page, and `generateMetadata` costs one statement. This is a different tool from `use cache`: `cache()` lives for one request and never crosses users, while `use cache` persists across requests and requires the key discipline described in [`rsc-no-request-apis-inside-use-cache`](rsc-no-request-apis-inside-use-cache.md). Note also that `React.cache` is isolated inside a `use cache` boundary — values memoized outside are not visible within.

Reference: [React — cache](https://react.dev/reference/react/cache) · [Next.js — Request memoization](https://nextjs.org/docs/app/guides/caching#request-memoization)
