---
title: Prevent Client-Side Fetch Cascades
impact: CRITICAL
impactDescription: Eliminates 2-5 unnecessary client round trips, 500-2000ms savings
tags: async, client, waterfall, useEffect, server-components
---

## Prevent Client-Side Fetch Cascades

Client-side fetching with useEffect creates waterfalls: parent fetches, renders children, then children fetch. Each level adds a full network round trip. Move data fetching to Server Components where requests can be parallelized and streamed.

**Incorrect (client-side cascade, 3 sequential round trips):**

```typescript
'use client'

import { useEffect, useState } from 'react'

export default function DashboardPage() {
  const [user, setUser] = useState<User | null>(null)

  useEffect(() => {
    fetch('/api/user').then(r => r.json()).then(setUser)  // Round trip 1
  }, [])

  if (!user) return <Loading />

  return (
    <div>
      <UserHeader user={user} />
      <OrdersSection userId={user.id} />  {/* Mounts after user loads */}
    </div>
  )
}

function OrdersSection({ userId }: { userId: string }) {
  const [orders, setOrders] = useState<Order[]>([])

  useEffect(() => {
    fetch(`/api/orders?userId=${userId}`).then(r => r.json()).then(setOrders)  // Round trip 2
  }, [userId])

  if (!orders.length) return <Loading />

  return (
    <div>
      {orders.map(order => (
        <OrderCard key={order.id} orderId={order.id} />  {/* Round trip 3 per card */}
      ))}
    </div>
  )
}
// Total: 3+ sequential network round trips from browser
```

**Correct (Server Component parallel fetching):**

```typescript
// app/dashboard/page.tsx (Server Component by default)
import { Suspense } from 'react'

export default async function DashboardPage() {
  const user = await getUser()  // Server-side, fast

  return (
    <div>
      <UserHeader user={user} />
      <Suspense fallback={<OrdersSkeleton />}>
        <OrdersSection userId={user.id} />
      </Suspense>
    </div>
  )
}

async function OrdersSection({ userId }: { userId: string }) {
  const orders = await getOrders(userId)  // Server-side, no browser round trip

  return (
    <div>
      {orders.map(order => (
        <OrderCard key={order.id} order={order} />
      ))}
    </div>
  )
}
// Total: 1 server render with parallel DB/API calls
```

**Alternative (preload pattern for necessary client fetches):**

```typescript
// When client-side fetching is required (real-time updates, user interactions)
'use client'

import { useEffect, useState } from 'react'

// Preload function called before component mounts
export function preloadDashboard() {
  void fetch('/api/user')
  void fetch('/api/orders')
  void fetch('/api/notifications')
}

export default function DashboardPage() {
  const [data, setData] = useState<DashboardData | null>(null)

  useEffect(() => {
    // Fetch all data in parallel, requests may already be in-flight
    Promise.all([
      fetch('/api/user').then(r => r.json()),
      fetch('/api/orders').then(r => r.json()),
      fetch('/api/notifications').then(r => r.json()),
    ]).then(([user, orders, notifications]) => {
      setData({ user, orders, notifications })
    })
  }, [])

  if (!data) return <Loading />

  return (
    <div>
      <UserHeader user={data.user} />
      <OrdersSection orders={data.orders} />
      <NotificationList notifications={data.notifications} />
    </div>
  )
}
```

**When client fetching is appropriate:**
- Real-time data that changes frequently (use SWR/React Query)
- User-triggered actions (search, filters)
- Data that depends on client-only state (geolocation)

Reference: [Server Components](https://nextjs.org/docs/app/getting-started/server-and-client-components)
