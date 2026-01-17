---
title: Fetch Data in Parallel in Server Components
impact: HIGH
impactDescription: eliminates server-side waterfalls, 2-5× faster
tags: server, parallel, data-fetching, promise-all
---

## Fetch Data in Parallel in Server Components

Initiate all independent data fetches simultaneously using `Promise.all()`. Sequential awaits create server-side waterfalls that multiply latency.

**Incorrect (sequential fetches, 3 round trips):**

```typescript
// app/dashboard/page.tsx
export default async function DashboardPage() {
  const user = await fetchUser()           // 200ms
  const orders = await fetchOrders()       // 150ms
  const notifications = await fetchNotifications()  // 100ms
  // Total: 450ms (sequential)

  return (
    <Dashboard
      user={user}
      orders={orders}
      notifications={notifications}
    />
  )
}
```

**Correct (parallel fetches, 1 round trip):**

```typescript
// app/dashboard/page.tsx
export default async function DashboardPage() {
  const [user, orders, notifications] = await Promise.all([
    fetchUser(),           // 200ms
    fetchOrders(),         // 150ms (parallel)
    fetchNotifications()   // 100ms (parallel)
  ])
  // Total: 200ms (longest request)

  return (
    <Dashboard
      user={user}
      orders={orders}
      notifications={notifications}
    />
  )
}
```

**With dependent data:**

```typescript
export default async function DashboardPage() {
  // First fetch user (needed for subsequent queries)
  const user = await fetchUser()

  // Then fetch user-dependent data in parallel
  const [orders, preferences] = await Promise.all([
    fetchOrders(user.id),
    fetchPreferences(user.id)
  ])

  return <Dashboard user={user} orders={orders} preferences={preferences} />
}
```
