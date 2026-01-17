---
title: Colocate Data Fetching with Components
impact: HIGH
impactDescription: eliminates prop drilling, enables streaming
tags: server, colocation, data-fetching, architecture
---

## Colocate Data Fetching with Components

Fetch data where it's needed, not in parent components. This enables independent streaming and eliminates prop drilling.

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
