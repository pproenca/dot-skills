---
title: Take the tenant id as an argument instead of reading cookies inside use cache
tags: rsc, use-cache, multi-tenancy, authorization
---

## Take the tenant id as an argument instead of reading cookies inside use cache

The natural way to write a cached per-user query is to resolve the session inside it, and `use cache` forbids exactly that: calling `cookies()` or `headers()` in a cached scope throws, because a cache entry is shared and request state would make it unshareable. That constraint is also the safety property. A cache entry's key is built from the function's arguments and captured closure variables and nothing else, so scoping data that never enters the signature never enters the key — and one tenant's rows get served to the next. Reading the session outside the cached function and passing the id in makes the query both legal and correctly partitioned.

```tsx
// app/dashboard/page.tsx
import { Suspense } from 'react'
import { getSession } from '@/lib/auth'
import { getOrganizationInvoices } from '@/lib/queries/invoices'

export default function DashboardPage() {
  return (
    <Suspense fallback={<InvoiceTableSkeleton />}>
      <OrganizationInvoices />
    </Suspense>
  )
}

async function OrganizationInvoices() {
  const { organizationId } = await getSession() // reads cookies — outside the cached scope
  const rows = await getOrganizationInvoices(organizationId)
  return <InvoiceTable rows={rows} />
}
```

```typescript
// lib/queries/invoices.ts
export async function getOrganizationInvoices(organizationId: number) {
  'use cache'
  cacheTag(`org-${organizationId}-invoices`)

  // organizationId is an argument, so it is part of the cache key.
  return db.select().from(invoices).where(eq(invoices.organizationId, organizationId))
}
```

**When NOT to use this pattern:** if the data is cheap to read and changes per request, skip `use cache` entirely — under Cache Components uncached is the default, and a Suspense boundary already keeps it off the critical path.

Reference: [Next.js — use cache: Cache keys and Constraints](https://nextjs.org/docs/app/api-reference/directives/use-cache)
