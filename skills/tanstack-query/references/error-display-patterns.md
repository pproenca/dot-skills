---
title: Display Errors Appropriately
impact: MEDIUM
impactDescription: improves UX, prevents silent failures
tags: error, display, ux, isError, error
---

## Display Errors Appropriately

Ignoring query errors leaves users confused. Display errors inline for recoverable issues, or redirect/toast for critical failures.

**Incorrect (error ignored):**

```typescript
function UserList() {
  const { data, isPending } = useQuery({
    queryKey: ['users'],
    queryFn: fetchUsers,
    // Error not destructured or handled!
  })

  if (isPending) return <Skeleton />
  return <ul>{data?.map(user => <li key={user.id}>{user.name}</li>)}</ul>
  // If error occurs: shows nothing, user has no idea why
}
```

**Correct (error displayed):**

```typescript
function UserList() {
  const { data, isPending, isError, error, refetch } = useQuery({
    queryKey: ['users'],
    queryFn: fetchUsers,
  })

  if (isPending) return <Skeleton />

  if (isError) {
    return (
      <div className="error-state">
        <p>Failed to load users: {error.message}</p>
        <button onClick={() => refetch()}>Retry</button>
      </div>
    )
  }

  return <ul>{data.map(user => <li key={user.id}>{user.name}</li>)}</ul>
}
```

**Partial error with stale data:**

```typescript
function UserList() {
  const { data, isError, error, isFetching } = useQuery({
    queryKey: ['users'],
    queryFn: fetchUsers,
  })

  return (
    <div>
      {/* Show stale data with error banner */}
      {isError && (
        <div className="bg-yellow-100 p-2">
          Failed to refresh: {error.message}
        </div>
      )}

      {/* Stale data still displayed */}
      {data && (
        <ul className={isFetching ? 'opacity-50' : ''}>
          {data.map(user => <li key={user.id}>{user.name}</li>)}
        </ul>
      )}
    </div>
  )
}
```

**Error-specific handling:**

```typescript
function UserProfile() {
  const { data, isError, error } = useQuery({
    queryKey: ['user', userId],
    queryFn: () => fetchUser(userId),
  })

  if (isError) {
    if (error instanceof ApiError) {
      if (error.status === 404) return <NotFound />
      if (error.status === 403) return <Forbidden />
    }
    return <GenericError error={error} />
  }

  return <Profile user={data} />
}
```
