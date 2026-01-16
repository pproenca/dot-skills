---
title: Fetch Data in Parallel with Promise.all
impact: CRITICAL
impactDescription: 2-5× faster data loading, eliminates sequential waterfalls
tags: async, parallel, promises, waterfalls, data-fetching
---

## Fetch Data in Parallel with Promise.all

Sequential awaits in async components create waterfalls where each fetch waits for the previous one. Use Promise.all to fetch independent data concurrently.

**Incorrect (sequential fetching, 3 round trips):**

```tsx
async function DashboardPage() {
  const user = await fetchUser()           // 200ms
  const orders = await fetchOrders()       // 300ms (waits for user)
  const notifications = await fetchNotifications()  // 150ms (waits for orders)
  // Total: 650ms

  return (
    <div>
      <UserHeader user={user} />
      <OrderList orders={orders} />
      <NotificationBell notifications={notifications} />
    </div>
  )
}
```

**Correct (parallel fetching, 1 round trip):**

```tsx
async function DashboardPage() {
  const [user, orders, notifications] = await Promise.all([
    fetchUser(),           // 200ms
    fetchOrders(),         // 300ms (concurrent)
    fetchNotifications(),  // 150ms (concurrent)
  ])
  // Total: 300ms (max of all three)

  return (
    <div>
      <UserHeader user={user} />
      <OrderList orders={orders} />
      <NotificationBell notifications={notifications} />
    </div>
  )
}
```

**Alternative (with Suspense streaming):**

```tsx
async function DashboardPage() {
  // Start all fetches immediately
  const userPromise = fetchUser()
  const ordersPromise = fetchOrders()
  const notificationsPromise = fetchNotifications()

  return (
    <div>
      <Suspense fallback={<HeaderSkeleton />}>
        <UserHeader userPromise={userPromise} />
      </Suspense>
      <Suspense fallback={<OrdersSkeleton />}>
        <OrderList ordersPromise={ordersPromise} />
      </Suspense>
      <Suspense fallback={<BellSkeleton />}>
        <NotificationBell notificationsPromise={notificationsPromise} />
      </Suspense>
    </div>
  )
}
// Each component streams as its data resolves
```

Reference: [Parallel Data Fetching](https://react.dev/reference/react/Suspense#revealing-content-together-at-once)
