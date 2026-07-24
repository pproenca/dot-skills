---
title: Push uncached queries below a Suspense boundary
tags: rsc, cache-components, suspense, streaming
---

## Push uncached queries below a Suspense boundary

Awaiting a query at the top of a page is the reflex, and with `cacheComponents: true` it costs the whole route its static shell. Next.js 16 prerenders everything above the first uncached read and streams the rest; a query awaited in the page body means there is nothing above it, so Next surfaces the `blocking-route` insight and the user waits on Postgres before seeing any markup. The fix is not to cache the query — it is to move it into a child so the shell containing the header, nav, and skeleton renders immediately.

**Incorrect (the whole route waits on Postgres):**

```tsx
// app/invoices/page.tsx
export default async function InvoicesPage() {
  const rows = await db.select().from(invoices).orderBy(desc(invoices.issuedAt)).limit(50)
  return (
    <>
      <h1>Invoices</h1>
      <InvoiceTable rows={rows} />
    </>
  )
}
```

**Correct (heading prerenders, table streams in):**

```tsx
// app/invoices/page.tsx
import { Suspense } from 'react'

export default function InvoicesPage() {
  return (
    <>
      <h1>Invoices</h1>
      <Suspense fallback={<InvoiceTableSkeleton />}>
        <RecentInvoices />
      </Suspense>
    </>
  )
}

async function RecentInvoices() {
  const rows = await db.select().from(invoices).orderBy(desc(invoices.issuedAt)).limit(50)
  return <InvoiceTable rows={rows} />
}
```

The same shape applies to `params` and `searchParams`: pass the promise down as a prop and await it inside the Suspense-wrapped child rather than at the top of the page.

When a page needs several independent queries, prefer one Suspense-wrapped component per section over collecting them into a single `Promise.all` in the page. `Promise.all` still makes the whole group wait for the slowest query before anything renders; separate boundaries let each section stream in as its own query resolves.

Reference: [Next.js — Migrating to Cache Components](https://nextjs.org/docs/app/guides/migrating-to-cache-components) · [Next.js — cacheComponents](https://nextjs.org/docs/app/api-reference/config/next-config-js/cacheComponents)
