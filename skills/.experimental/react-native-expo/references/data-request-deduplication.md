---
title: Deduplicate Concurrent Requests
impact: HIGH
impactDescription: eliminates redundant network calls
tags: data, deduplication, swr, react-query, caching
---

## Deduplicate Concurrent Requests

Multiple components requesting the same data should share a single network request, not make duplicate calls.

**Incorrect (duplicate requests):**

```tsx
// components/Header.tsx
function Header() {
  const [user, setUser] = useState(null)
  useEffect(() => {
    fetchUser().then(setUser)  // Request 1
  }, [])
  return <Text>{user?.name}</Text>
}

// components/Sidebar.tsx
function Sidebar() {
  const [user, setUser] = useState(null)
  useEffect(() => {
    fetchUser().then(setUser)  // Request 2 (duplicate!)
  }, [])
  return <Avatar uri={user?.avatar} />
}

// components/ProfileBadge.tsx
function ProfileBadge() {
  const [user, setUser] = useState(null)
  useEffect(() => {
    fetchUser().then(setUser)  // Request 3 (duplicate!)
  }, [])
  return <Badge role={user?.role} />
}
// Three identical network requests
```

**Correct (deduplicated with TanStack Query):**

```tsx
// All components share the same cached data
// components/Header.tsx
function Header() {
  const { data: user } = useQuery(['user'], fetchUser)
  return <Text>{user?.name}</Text>
}

// components/Sidebar.tsx
function Sidebar() {
  const { data: user } = useQuery(['user'], fetchUser)
  return <Avatar uri={user?.avatar} />
}

// components/ProfileBadge.tsx
function ProfileBadge() {
  const { data: user } = useQuery(['user'], fetchUser)
  return <Badge role={user?.role} />
}
// Single network request, data shared across components
```

**Configure stale time to prevent refetches:**

```tsx
// _layout.tsx or App.tsx
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60,  // Data fresh for 1 minute
      cacheTime: 1000 * 60 * 5,  // Cache for 5 minutes
    }
  }
})

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <AppContent />
    </QueryClientProvider>
  )
}
```

**Alternative with SWR:**

```tsx
import useSWR from 'swr'

function Header() {
  const { data: user } = useSWR('/api/user', fetcher)
  return <Text>{user?.name}</Text>
}

function Sidebar() {
  // Same key = same cached data, single request
  const { data: user } = useSWR('/api/user', fetcher)
  return <Avatar uri={user?.avatar} />
}
```

**Manual deduplication (if not using a library):**

```tsx
// lib/dedupe.ts
const pending = new Map()

export async function fetchWithDedupe(key, fetcher) {
  if (pending.has(key)) {
    return pending.get(key)
  }

  const promise = fetcher().finally(() => {
    pending.delete(key)
  })

  pending.set(key, promise)
  return promise
}

// Usage
const user = await fetchWithDedupe('user', fetchUser)
```

**Benefits:**
- Reduces network traffic
- Faster response (cached data)
- Lower battery consumption
- Consistent data across components

Reference: [TanStack Query Deduplication](https://tanstack.com/query/latest/docs/react/guides/important-defaults)
