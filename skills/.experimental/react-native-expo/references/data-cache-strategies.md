---
title: Configure Appropriate Cache Strategies
impact: MEDIUM
impactDescription: reduces unnecessary refetches
tags: data, caching, stale-time, cache-time, react-query
---

## Configure Appropriate Cache Strategies

Different data types need different caching strategies. Static data should cache longer than real-time data.

**Incorrect (same cache settings for all data):**

```tsx
// Global default: everything refetches immediately
const queryClient = new QueryClient()

function App() {
  // User profile refetches on every mount
  const { data: user } = useQuery(['user'], fetchUser)

  // Static config refetches on every mount
  const { data: config } = useQuery(['config'], fetchConfig)

  // Real-time prices refetch on every mount (correct here)
  const { data: prices } = useQuery(['prices'], fetchPrices)

  // ...
}
```

**Correct (tailored cache strategies):**

```tsx
// Static data: cache for hours
const { data: config } = useQuery({
  queryKey: ['config'],
  queryFn: fetchConfig,
  staleTime: 1000 * 60 * 60,  // Fresh for 1 hour
  cacheTime: 1000 * 60 * 60 * 24,  // Cache for 24 hours
})

// User data: cache for minutes
const { data: user } = useQuery({
  queryKey: ['user'],
  queryFn: fetchUser,
  staleTime: 1000 * 60 * 5,  // Fresh for 5 minutes
  cacheTime: 1000 * 60 * 30,  // Cache for 30 minutes
})

// Real-time data: always refetch
const { data: prices } = useQuery({
  queryKey: ['prices'],
  queryFn: fetchPrices,
  staleTime: 0,  // Always stale
  refetchInterval: 5000,  // Poll every 5 seconds
})
```

**Configure defaults by query key prefix:**

```tsx
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60,  // Default: 1 minute
      cacheTime: 1000 * 60 * 5,  // Default: 5 minutes
      refetchOnWindowFocus: true,
      retry: 2,
    },
  },
})

// Override for specific queries
queryClient.setQueryDefaults(['static'], {
  staleTime: Infinity,  // Never stale
  cacheTime: Infinity,  // Never garbage collected
})

queryClient.setQueryDefaults(['realtime'], {
  staleTime: 0,
  cacheTime: 1000 * 60,
  refetchOnMount: true,
  refetchOnWindowFocus: true,
})
```

**Cache strategy guidelines:**

| Data Type | staleTime | cacheTime | refetchInterval |
|-----------|-----------|-----------|-----------------|
| Static config | Infinity | Infinity | - |
| User profile | 5 min | 30 min | - |
| Feed/timeline | 30 sec | 5 min | - |
| Search results | 0 | 1 min | - |
| Real-time prices | 0 | 1 min | 5 sec |
| Notifications | 0 | 0 | 30 sec |

**Persist cache across sessions:**

```tsx
import AsyncStorage from '@react-native-async-storage/async-storage'
import { createAsyncStoragePersister } from '@tanstack/query-async-storage-persister'
import { PersistQueryClientProvider } from '@tanstack/react-query-persist-client'

const persister = createAsyncStoragePersister({
  storage: AsyncStorage,
})

function App() {
  return (
    <PersistQueryClientProvider
      client={queryClient}
      persistOptions={{ persister }}
    >
      <AppContent />
    </PersistQueryClientProvider>
  )
}
// Cache survives app restart
```

Reference: [TanStack Query Caching](https://tanstack.com/query/latest/docs/react/guides/caching)
