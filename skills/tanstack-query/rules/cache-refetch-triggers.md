---
title: Control Automatic Refetch Triggers
impact: MEDIUM
impactDescription: prevents unexpected refetches, saves bandwidth
tags: cache, refetch, windowFocus, reconnect, mount
---

## Control Automatic Refetch Triggers

TanStack Query refetches stale queries on window focus, reconnect, and component mount. These defaults are aggressive—disable them when inappropriate.

**Default behavior (often surprising):**

```typescript
// With defaults, this query refetches when:
// 1. Window regains focus (user switches tabs back)
// 2. Network reconnects
// 3. Component mounts (if data is stale)
const { data } = useQuery({
  queryKey: ['heavyReport'],
  queryFn: fetchHeavyReport, // Takes 10 seconds, 5MB response
})
```

**Controlled refetching:**

```typescript
// Expensive query - don't refetch on focus/reconnect
const { data: report } = useQuery({
  queryKey: ['heavyReport'],
  queryFn: fetchHeavyReport,
  refetchOnWindowFocus: false, // Don't refetch when tab focuses
  refetchOnReconnect: false,   // Don't refetch on network restore
  refetchOnMount: false,       // Don't refetch if we have cached data
  staleTime: 30 * 60 * 1000,   // Consider fresh for 30 minutes
})

// Real-time data - aggressive refetching appropriate
const { data: notifications } = useQuery({
  queryKey: ['notifications'],
  queryFn: fetchNotifications,
  refetchOnWindowFocus: 'always', // Refetch even if fresh
  refetchInterval: 30_000,         // Poll every 30 seconds
})

// User-specific data - refetch on focus if stale
const { data: user } = useQuery({
  queryKey: ['currentUser'],
  queryFn: fetchCurrentUser,
  refetchOnWindowFocus: true, // Default - refetch if stale
  staleTime: 60_000,          // Fresh for 1 minute
})
```

**Conditional refetching:**

```typescript
const { data } = useQuery({
  queryKey: ['dashboard'],
  queryFn: fetchDashboard,
  // Only refetch on focus if tab was away > 5 minutes
  refetchOnWindowFocus: (query) => {
    const fiveMinutes = 5 * 60 * 1000
    const lastUpdated = query.state.dataUpdatedAt
    return Date.now() - lastUpdated > fiveMinutes
  },
})
```
