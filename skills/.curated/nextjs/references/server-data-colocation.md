---
title: Each Server Component fetches the data it renders — pull data to the leaf, not the route root
impact: HIGH
impactDescription: eliminates prop-drilling for fetched data, unblocks per-subtree streaming, removes the "fetch everything in page.tsx" bottleneck
tags: server, data-colocation, fetch-at-leaf, no-prop-drilling
---

## Each Server Component fetches the data it renders — pull data to the leaf, not the route root

**Pattern intent:** the Server Component that *renders* a piece of data is also the one that *fetches* it. This is what unlocks per-subtree Suspense streaming, removes prop-drilling, and (with `react.cache`) deduplicates shared fetches automatically.

### Shapes to recognize

- A `page.tsx` that awaits N fetches at the top and passes everything down through props — every child renders only after everything is fetched.
- A layout that pre-fetches and passes data down through children — defeats per-subtree streaming.
- A pattern where the page acts as "data-loader" and child components are "pure renderers" — feels clean but blocks streaming and over-fetches when child rendering changes.
- A custom prop named `data` or `loaderData` carrying everything a subtree needs — Remix-style loaders ported into App Router without restructuring.
- Workaround: pre-fetching at the top "for SEO" — usually unnecessary; Server Components SSR by default and streaming is SEO-safe.

The canonical resolution: move each `await fetch(...)` (or `await db.x.findUnique(...)`) into the Server Component that actually renders the result. Wrap shared fetchers in `cache()` so they dedupe across components. Wrap subtrees in `<Suspense>` so each streams independently.

**Incorrect (fetching in parent, prop drilling):**

```typescript
// app/dashboard/page.tsx
export default async function DashboardPage() {
  const user = await fetchUser()
  const orders = await fetchOrders(user.id)
  const notifications = await fetchNotifications(user.id)

  return (
    <Dashboard>
      <Header user={user} />
      <OrderList orders={orders} user={user} />
      <NotificationPanel notifications={notifications} userId={user.id} />
    </Dashboard>
  )
}
// All data fetched sequentially, no streaming possible
```

**Correct (colocated data fetching):**

```typescript
// app/dashboard/page.tsx
import { Suspense } from 'react'

export default function DashboardPage() {
  return (
    <Dashboard>
      <Suspense fallback={<HeaderSkeleton />}>
        <Header />
      </Suspense>
      <Suspense fallback={<OrdersSkeleton />}>
        <OrderList />
      </Suspense>
      <Suspense fallback={<NotificationsSkeleton />}>
        <NotificationPanel />
      </Suspense>
    </Dashboard>
  )
}

// components/OrderList.tsx
async function OrderList() {
  const user = await getUser()  // Deduplicated with cache()
  const orders = await fetchOrders(user.id)
  return <ul>{orders.map(o => <OrderItem key={o.id} order={o} />)}</ul>
}
// Each component fetches what it needs, streams independently
```

**Note:** Use `cache()` to deduplicate shared data like user across components.
