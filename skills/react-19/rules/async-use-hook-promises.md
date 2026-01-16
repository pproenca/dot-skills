---
title: Use the use Hook for Promise Reading
impact: CRITICAL
impactDescription: eliminates useEffect/useState boilerplate, integrates with Suspense
tags: async, use, promises, suspense, data-fetching
---

## Use the use Hook for Promise Reading

The `use` hook reads promises during render and integrates with Suspense. Traditional useEffect patterns require managing loading states manually and cause waterfalls.

**Incorrect (useEffect waterfall, manual loading state):**

```tsx
function UserProfile({ userId }: { userId: string }) {
  const [user, setUser] = useState<User | null>(null)
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    setIsLoading(true)
    fetchUser(userId)
      .then(setUser)
      .finally(() => setIsLoading(false))
  }, [userId])

  if (isLoading) return <Skeleton />  // Two renders: loading then data
  if (!user) return null

  return <div>{user.name}</div>
}
```

**Correct (Suspense integration, single render path):**

```tsx
function UserProfile({ userPromise }: { userPromise: Promise<User> }) {
  const user = use(userPromise)  // Suspends until resolved

  return <div>{user.name}</div>
}

// Parent provides the promise
function ProfilePage({ userId }: { userId: string }) {
  const userPromise = fetchUser(userId)  // Created outside render

  return (
    <Suspense fallback={<Skeleton />}>
      <UserProfile userPromise={userPromise} />
    </Suspense>
  )
}
```

**Benefits:**
- No useState/useEffect boilerplate
- Automatic Suspense integration
- Can be called conditionally (unlike hooks)
- Works in loops and early returns

**When NOT to use this pattern:**
- Promise created during render (causes infinite re-renders)
- Need fine-grained control over loading states

Reference: [use Hook](https://react.dev/reference/react/use)
