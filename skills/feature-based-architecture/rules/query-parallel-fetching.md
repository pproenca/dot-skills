---
title: Fetch Independent Data in Parallel
impact: HIGH
impactDescription: Reduces total load time by ~50% for pages with multiple data sources
tags: query, parallel, performance, waterfall
---

## Fetch Independent Data in Parallel

When a component needs multiple pieces of unrelated data, fetch them in parallel using Promise.all(). Sequential fetching creates waterfalls where total time equals the sum of all requests.

**Incorrect (sequential waterfall):**

```typescript
// Each request waits for the previous one
// Total time: 200ms + 150ms + 100ms = 450ms
export async function DashboardPage() {
  const user = await getUser(userId);        // 200ms
  const orders = await getOrders(userId);    // 150ms
  const notifications = await getNotifications(userId);  // 100ms

  return <Dashboard user={user} orders={orders} notifications={notifications} />;
}
```

**Correct (parallel fetching):**

```typescript
// All requests start simultaneously
// Total time: max(200ms, 150ms, 100ms) = 200ms
export async function DashboardPage() {
  const [user, orders, notifications] = await Promise.all([
    getUser(userId),           // 200ms
    getOrders(userId),         // 150ms
    getNotifications(userId),  // 100ms
  ]);

  return <Dashboard user={user} orders={orders} notifications={notifications} />;
}
```

**With React Query:**

```typescript
// src/app/pages/DashboardPage.tsx
export function DashboardPage({ userId }: { userId: string }) {
  // These queries run in parallel automatically
  const userQuery = useUser(userId);
  const ordersQuery = useOrders(userId);
  const notificationsQuery = useNotifications(userId);

  if (userQuery.isLoading || ordersQuery.isLoading || notificationsQuery.isLoading) {
    return <Loading />;
  }

  return (
    <Dashboard
      user={userQuery.data}
      orders={ordersQuery.data}
      notifications={notificationsQuery.data}
    />
  );
}
```

**When sequential is necessary:**
- Second request depends on first request's result
- Rate limiting requires throttled requests
- User must complete a step before seeing next data

Reference: [Robin Wieruch - React Feature Architecture](https://www.robinwieruch.de/react-feature-architecture/)
