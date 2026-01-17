---
title: Fetch Data in Parallel with Promise.all
impact: MEDIUM-HIGH
impactDescription: eliminates waterfalls, 2-5× faster
tags: data, parallel, promise-all, waterfall
---

## Fetch Data in Parallel with Promise.all

When multiple data fetches are independent, run them in parallel. Sequential awaits create waterfalls that multiply latency.

**Incorrect (sequential fetching):**

```typescript
async function Dashboard() {
  const user = await fetchUser()           // 200ms
  const orders = await fetchOrders()       // 150ms
  const analytics = await fetchAnalytics() // 300ms
  // Total: 650ms (sum of all)

  return (
    <div>
      <UserCard user={user} />
      <OrderList orders={orders} />
      <AnalyticsChart data={analytics} />
    </div>
  )
}
```

**Correct (parallel fetching):**

```typescript
async function Dashboard() {
  const [user, orders, analytics] = await Promise.all([
    fetchUser(),       // 200ms
    fetchOrders(),     // 150ms (parallel)
    fetchAnalytics()   // 300ms (parallel)
  ])
  // Total: 300ms (max of all)

  return (
    <div>
      <UserCard user={user} />
      <OrderList orders={orders} />
      <AnalyticsChart data={analytics} />
    </div>
  )
}
```

**With error handling:**

```typescript
async function Dashboard() {
  const results = await Promise.allSettled([
    fetchUser(),
    fetchOrders(),
    fetchAnalytics()
  ])

  const user = results[0].status === 'fulfilled' ? results[0].value : null
  const orders = results[1].status === 'fulfilled' ? results[1].value : []
  const analytics = results[2].status === 'fulfilled' ? results[2].value : null

  return (
    <div>
      {user ? <UserCard user={user} /> : <UserError />}
      <OrderList orders={orders} />
      {analytics && <AnalyticsChart data={analytics} />}
    </div>
  )
}
```
