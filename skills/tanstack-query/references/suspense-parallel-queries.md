---
title: Combine Suspense Queries with useSuspenseQueries
impact: MEDIUM
impactDescription: prevents waterfall in suspense components
tags: suspense, useSuspenseQueries, parallel, waterfalls
---

## Combine Suspense Queries with useSuspenseQueries

Multiple `useSuspenseQuery` calls in one component create waterfalls—each suspends sequentially. Use `useSuspenseQueries` to fetch in parallel.

**Incorrect (sequential suspension):**

```typescript
function Dashboard() {
  // First query suspends
  const { data: user } = useSuspenseQuery({
    queryKey: ['user'],
    queryFn: fetchUser,
  })

  // Only starts AFTER user query resolves!
  const { data: stats } = useSuspenseQuery({
    queryKey: ['stats'],
    queryFn: fetchStats,
  })

  // Third waterfall
  const { data: notifications } = useSuspenseQuery({
    queryKey: ['notifications'],
    queryFn: fetchNotifications,
  })

  return <div>...</div>
}
// Total time: 100ms + 100ms + 100ms = 300ms
```

**Correct (parallel suspension):**

```typescript
function Dashboard() {
  const [
    { data: user },
    { data: stats },
    { data: notifications },
  ] = useSuspenseQueries({
    queries: [
      { queryKey: ['user'], queryFn: fetchUser },
      { queryKey: ['stats'], queryFn: fetchStats },
      { queryKey: ['notifications'], queryFn: fetchNotifications },
    ],
  })

  return <div>...</div>
}
// Total time: max(100ms, 100ms, 100ms) = 100ms
```

**With queryOptions for type safety:**

```typescript
const dashboardQueries = {
  user: queryOptions({
    queryKey: ['user'],
    queryFn: fetchUser,
  }),
  stats: queryOptions({
    queryKey: ['stats'],
    queryFn: fetchStats,
  }),
  notifications: queryOptions({
    queryKey: ['notifications'],
    queryFn: fetchNotifications,
  }),
}

function Dashboard() {
  const [
    { data: user },
    { data: stats },
    { data: notifications },
  ] = useSuspenseQueries({
    queries: [
      dashboardQueries.user,
      dashboardQueries.stats,
      dashboardQueries.notifications,
    ],
  })

  return <div>...</div>
}
```
