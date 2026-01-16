---
title: Understand staleTime vs gcTime
impact: CRITICAL
impactDescription: prevents unnecessary refetches and memory issues
tags: cache, staleTime, gcTime, configuration, fundamentals
---

## Understand staleTime vs gcTime

`staleTime` and `gcTime` are the most misunderstood TanStack Query options. Confusing them causes excessive refetching or stale data. `gcTime` was renamed from `cacheTime` in v5 because of this confusion.

**staleTime**: How long data stays "fresh." Fresh data won't trigger background refetches.

**gcTime**: How long *unused* queries stay in memory before garbage collection.

**Incorrect (default staleTime causes refetch storms):**

```typescript
// staleTime defaults to 0 - data is immediately stale
const { data } = useQuery({
  queryKey: ['user', userId],
  queryFn: fetchUser,
  // staleTime: 0 (default) - every component mount triggers refetch
})

// User navigates away and back - unnecessary refetch!
// Another component mounts with same key - another refetch!
```

**Correct (appropriate staleTime for use case):**

```typescript
// Static data - rarely changes
const { data: config } = useQuery({
  queryKey: ['appConfig'],
  queryFn: fetchConfig,
  staleTime: Infinity, // Never refetch unless manually invalidated
  gcTime: Infinity,    // Keep in cache forever
})

// User data - may change, but not every second
const { data: user } = useQuery({
  queryKey: ['user', userId],
  queryFn: fetchUser,
  staleTime: 5 * 60 * 1000, // Fresh for 5 minutes
})

// Real-time data - always fresh from server
const { data: notifications } = useQuery({
  queryKey: ['notifications'],
  queryFn: fetchNotifications,
  staleTime: 0, // Always refetch on focus/mount (default)
  refetchInterval: 30_000, // Also poll every 30s
})
```

**Common mistake - gcTime less than staleTime:**

```typescript
// Problematic: data expires from cache before it goes stale
const { data } = useQuery({
  queryKey: ['users'],
  queryFn: fetchUsers,
  staleTime: 10 * 60 * 1000, // 10 minutes
  gcTime: 5 * 60 * 1000,     // 5 minutes - cache gone before stale!
})
```

**Rule of thumb:** `gcTime >= staleTime` to ensure cached data is available when needed.

Reference: [Important Defaults](https://tanstack.com/query/v5/docs/react/guides/important-defaults)
