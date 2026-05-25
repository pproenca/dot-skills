---
title: Wrap uncached or runtime reads in Suspense or the build fails
tags: shell, suspense, build-error, blocking-route
---

## Wrap uncached or runtime reads in Suspense or the build fails

With Cache Components, any component that reads uncached or runtime data must be either inside `<Suspense>` or marked `'use cache'`. Omit both and the build fails with `Uncached data was accessed outside of <Suspense>` — there is no silent fallback to a fully dynamic page like in Next.js 15. The error is the framework forcing you to declare the boundary; the fix is to extract the data-reading component and wrap it, not to suppress it.

**Incorrect (build error — uncached fetch at the page root):**

```tsx
export default async function DashboardPage() {
  const orders = await fetch('https://api.acme.com/orders').then((r) => r.json())
  return <OrdersTable orders={orders} />
}
```

**Correct (extract the dynamic part, wrap it in a boundary):**

```tsx
import { Suspense } from 'react'

export default function DashboardPage() {
  return (
    <Suspense fallback={<OrdersTableSkeleton />}>
      <Orders />
    </Suspense>
  )
}

async function Orders() {
  const orders = await fetch('https://api.acme.com/orders').then((r) => r.json())
  return <OrdersTable orders={orders} />
}
```

Reference: [Caching — how rendering works](https://nextjs.org/docs/app/getting-started/caching#how-rendering-works)
