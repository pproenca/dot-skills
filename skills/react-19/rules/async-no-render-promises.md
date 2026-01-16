---
title: Never Create Promises During Render
impact: CRITICAL
impactDescription: prevents infinite re-render loops
tags: async, use, promises, render, anti-pattern
---

## Never Create Promises During Render

Creating promises inside a component that calls `use` causes infinite re-renders. Each render creates a new promise, which triggers a new render when resolved.

**Incorrect (promise created during render):**

```tsx
function UserProfile({ userId }: { userId: string }) {
  const userPromise = fetchUser(userId)  // New promise every render!
  const user = use(userPromise)  // Infinite loop

  return <div>{user.name}</div>
}
```

**Correct (promise created outside render):**

```tsx
// Option 1: Pass promise from parent
function UserProfile({ userPromise }: { userPromise: Promise<User> }) {
  const user = use(userPromise)
  return <div>{user.name}</div>
}

function ProfilePage({ userId }: { userId: string }) {
  const userPromise = useMemo(() => fetchUser(userId), [userId])

  return (
    <Suspense fallback={<Skeleton />}>
      <UserProfile userPromise={userPromise} />
    </Suspense>
  )
}

// Option 2: Use React cache() for deduplication
import { cache } from 'react'

const fetchUser = cache(async (userId: string) => {
  const res = await fetch(`/api/users/${userId}`)
  return res.json()
})

function UserProfile({ userId }: { userId: string }) {
  const user = use(fetchUser(userId))  // Cached per request
  return <div>{user.name}</div>
}

// Option 3: Create in Server Component
async function ProfilePage({ userId }: { userId: string }) {
  const userPromise = fetchUser(userId)  // Server Components don't re-render

  return (
    <Suspense fallback={<Skeleton />}>
      <UserProfile userPromise={userPromise} />
    </Suspense>
  )
}
```

**Best practices:**
- Create promises in Server Components (stable across renders)
- Use caching libraries (SWR, React Query) for Client Components
- Wrap with useMemo if creating in parent component

Reference: [use Hook Caveats](https://react.dev/reference/react/use#caveats)
