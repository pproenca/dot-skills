---
title: Fetch Independent Data in Parallel
impact: MEDIUM
impactDescription: 2-5× faster screen load time
tags: async, parallel, Promise.all, waterfalls
---

## Fetch Independent Data in Parallel

Sequential awaits create network waterfalls where each request waits for the previous to complete. Use `Promise.all()` for independent requests to run them concurrently.

**Incorrect (sequential requests, 3 round trips):**

```typescript
// screens/Dashboard.tsx
export function Dashboard({ userId }: Props) {
  const [data, setData] = useState<DashboardData | null>(null);

  useEffect(() => {
    async function loadData() {
      const user = await fetchUser(userId);
      const orders = await fetchOrders(userId);
      const notifications = await fetchNotifications(userId);
      setData({ user, orders, notifications });
    }
    loadData();
  }, [userId]);

  return data ? <DashboardView data={data} /> : <Loading />;
}
// Total time: user + orders + notifications (e.g., 300 + 400 + 200 = 900ms)
```

**Correct (parallel requests, 1 round trip):**

```typescript
// screens/Dashboard.tsx
export function Dashboard({ userId }: Props) {
  const [data, setData] = useState<DashboardData | null>(null);

  useEffect(() => {
    async function loadData() {
      const [user, orders, notifications] = await Promise.all([
        fetchUser(userId),
        fetchOrders(userId),
        fetchNotifications(userId),
      ]);
      setData({ user, orders, notifications });
    }
    loadData();
  }, [userId]);

  return data ? <DashboardView data={data} /> : <Loading />;
}
// Total time: max(user, orders, notifications) (e.g., 400ms)
```

**When NOT to parallelize:** When requests depend on each other (e.g., need user.id for orders).

Reference: [Promise.all](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/all)
