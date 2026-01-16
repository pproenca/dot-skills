---
title: Use Promise.all() for Independent Data Fetches
impact: CRITICAL
impactDescription: 2-5× faster page loads, eliminates N-1 unnecessary round trips
tags: async, parallel, promises, waterfalls, performance
---

## Use Promise.all() for Independent Data Fetches

Sequential awaits create request waterfalls where each fetch waits for the previous one to complete. When fetches are independent, use Promise.all() to execute them concurrently and reduce total wait time to the duration of the slowest request.

**Incorrect (sequential fetching creates waterfall):**

```typescript
async function DashboardPage() {
  const user = await getUser()              // 200ms
  const orders = await getOrders()          // 300ms waits for user to complete
  const notifications = await getNotifications()  // 150ms waits for orders
  // Total: 650ms sequential

  return (
    <div>
      <UserProfile user={user} />
      <OrderHistory orders={orders} />
      <NotificationList notifications={notifications} />
    </div>
  )
}
```

**Correct (parallel fetching eliminates waterfall):**

```typescript
async function DashboardPage() {
  // Start all fetches immediately, await together
  const [user, orders, notifications] = await Promise.all([
    getUser(),              // 200ms concurrent
    getOrders(),            // 300ms concurrent
    getNotifications(),     // 150ms concurrent
  ])
  // Total: 300ms (slowest request only)

  return (
    <div>
      <UserProfile user={user} />
      <OrderHistory orders={orders} />
      <NotificationList notifications={notifications} />
    </div>
  )
}
```

**Alternative (start early, await later):**

```typescript
async function DashboardPage() {
  // Initiate requests immediately (no await)
  const userPromise = getUser()
  const ordersPromise = getOrders()
  const notificationsPromise = getNotifications()

  // Await when values are needed
  const [user, orders, notifications] = await Promise.all([
    userPromise,
    ordersPromise,
    notificationsPromise,
  ])

  return (
    <div>
      <UserProfile user={user} />
      <OrderHistory orders={orders} />
      <NotificationList notifications={notifications} />
    </div>
  )
}
```

**When NOT to use:**
- When fetches depend on each other (e.g., need userId before fetching orders)
- When you want progressive streaming with Suspense boundaries instead

Reference: [Parallel Data Fetching](https://nextjs.org/docs/app/getting-started/fetching-data#parallel-data-fetching)
