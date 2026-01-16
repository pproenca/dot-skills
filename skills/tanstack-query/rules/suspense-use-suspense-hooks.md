---
title: Use Suspense Hooks for Simpler Loading States
impact: MEDIUM
impactDescription: eliminates loading checks, cleaner component code
tags: suspense, useSuspenseQuery, loading, react
---

## Use Suspense Hooks for Simpler Loading States

`useSuspenseQuery` suspends the component during loading, guaranteeing `data` is defined when the component renders. This eliminates loading state checks and simplifies component logic.

**Without Suspense (loading checks everywhere):**

```typescript
function UserProfile({ userId }: { userId: string }) {
  const { data: user, isPending, error } = useQuery({
    queryKey: ['user', userId],
    queryFn: () => fetchUser(userId),
  })

  if (isPending) return <Skeleton />
  if (error) return <ErrorDisplay error={error} />

  // data might still be undefined if enabled was false
  return <div>{user?.name}</div>
}
```

**With Suspense (data always defined):**

```typescript
import { useSuspenseQuery } from '@tanstack/react-query'

function UserProfile({ userId }: { userId: string }) {
  const { data: user } = useSuspenseQuery({
    queryKey: ['user', userId],
    queryFn: () => fetchUser(userId),
  })

  // data is GUARANTEED to be defined here
  return <div>{user.name}</div>
}

// Parent handles loading via Suspense boundary
function UserProfilePage({ userId }: { userId: string }) {
  return (
    <ErrorBoundary fallback={<ErrorDisplay />}>
      <Suspense fallback={<Skeleton />}>
        <UserProfile userId={userId} />
      </Suspense>
    </ErrorBoundary>
  )
}
```

**Key differences from useQuery:**

| Feature | useQuery | useSuspenseQuery |
|---------|----------|------------------|
| `data` type | `T \| undefined` | `T` (guaranteed) |
| `isPending` | Can be `true` | Always `false` |
| `status` | `'pending' \| 'error' \| 'success'` | `'error' \| 'success'` |
| `enabled` option | Supported | Not supported |
| `placeholderData` | Supported | Not supported |

**Important:** `enabled: false` is not compatible with Suspense because the component would suspend forever waiting for data that will never come.
