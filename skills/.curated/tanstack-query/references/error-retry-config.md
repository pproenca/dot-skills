---
title: Configure Retry with Exponential Backoff
impact: MEDIUM
impactDescription: balances recovery vs user wait time
tags: error, retry, backoff, configuration
---

## Configure Retry with Exponential Backoff

Default retry (3 attempts with exponential backoff) is aggressive for some queries and insufficient for others. Configure retry based on operation importance and expected failure modes.

**Default behavior:**

```typescript
// Retries 3 times with exponential backoff (1s, 2s, 4s)
// Total: up to 7 seconds before error shows
useQuery({
  queryKey: ['data'],
  queryFn: fetchData,
  // retry: 3 (default)
  // retryDelay: attempt => Math.min(1000 * 2 ** attempt, 30000) (default)
})
```

**Fast-fail for user-initiated actions:**

```typescript
// User clicks search - don't make them wait
useQuery({
  queryKey: ['search', query],
  queryFn: () => search(query),
  retry: 1,              // One retry only
  retryDelay: 500,       // Quick retry
})
```

**Patient retry for background data:**

```typescript
// Dashboard widget - can wait for recovery
useQuery({
  queryKey: ['analytics'],
  queryFn: fetchAnalytics,
  retry: 5,
  retryDelay: (attempt) => Math.min(1000 * 2 ** attempt, 60000),
})
```

**Custom backoff strategies:**

```typescript
// Linear backoff: 1s, 2s, 3s, 4s
retryDelay: (attempt) => attempt * 1000,

// Fixed delay: always 2s
retryDelay: 2000,

// Jittered backoff (prevents thundering herd)
retryDelay: (attempt) => {
  const base = Math.min(1000 * 2 ** attempt, 30000)
  const jitter = Math.random() * 1000
  return base + jitter
},
```

**Global defaults:**

```typescript
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 2,
      retryDelay: (attempt) => Math.min(1000 * 2 ** attempt, 10000),
    },
    mutations: {
      retry: 0, // Don't retry mutations by default
    },
  },
})
```
