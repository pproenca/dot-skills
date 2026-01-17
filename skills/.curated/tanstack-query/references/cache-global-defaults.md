---
title: Configure Global Defaults Appropriately
impact: CRITICAL
impactDescription: prevents per-query repetition, establishes sensible baselines
tags: cache, defaults, QueryClient, configuration
---

## Configure Global Defaults Appropriately

TanStack Query's defaults prioritize freshness over performance—`staleTime: 0` refetches on every mount. Configure global defaults to match your app's data patterns, then override per-query.

**Incorrect (accepting aggressive defaults):**

```typescript
// Default QueryClient - every query refetches on mount/focus
const queryClient = new QueryClient()

// Every query across the app repeats these overrides
const { data } = useQuery({
  queryKey: ['users'],
  queryFn: fetchUsers,
  staleTime: 5 * 60 * 1000,
  retry: 2,
})
```

**Correct (sensible global defaults):**

```typescript
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 60 * 1000,           // 1 minute default freshness
      gcTime: 5 * 60 * 1000,          // 5 minute cache retention
      retry: 1,                        // Retry once on failure
      refetchOnWindowFocus: 'always', // Refetch stale on focus
      refetchOnReconnect: 'always',   // Refetch stale on reconnect
    },
    mutations: {
      retry: 0, // Don't retry mutations by default
    },
  },
})

// Queries now inherit sensible defaults
const { data } = useQuery({
  queryKey: ['users'],
  queryFn: fetchUsers,
  // Inherits staleTime: 60_000, retry: 1, etc.
})

// Override only when needed
const { data: config } = useQuery({
  queryKey: ['appConfig'],
  queryFn: fetchConfig,
  staleTime: Infinity, // Static data, override default
})
```

**Environment-specific defaults:**

```typescript
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: process.env.NODE_ENV === 'development'
        ? 0              // Fresh data in dev for debugging
        : 60 * 1000,     // 1 minute in production
      retry: process.env.NODE_ENV === 'test' ? 0 : 1,
    },
  },
})
```
