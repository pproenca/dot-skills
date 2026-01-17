---
title: Use enabled for Conditional Queries
impact: HIGH
impactDescription: prevents invalid requests, enables dependent queries
tags: cache, enabled, conditional, dependent-queries
---

## Use enabled for Conditional Queries

Queries run immediately by default. Use `enabled` to defer queries until dependencies are available—essential for dependent queries and conditional fetching.

**Incorrect (query runs with undefined parameter):**

```typescript
function UserProfile({ userId }: { userId?: string }) {
  // Runs immediately, even when userId is undefined!
  const { data } = useQuery({
    queryKey: ['user', userId],
    queryFn: () => fetchUser(userId!), // Dangerous assertion
  })
  // API receives: GET /users/undefined
}
```

**Correct (enabled guards the query):**

```typescript
function UserProfile({ userId }: { userId?: string }) {
  const { data, isPending } = useQuery({
    queryKey: ['user', userId],
    queryFn: () => fetchUser(userId!),
    enabled: !!userId, // Only run when userId exists
  })

  if (!userId) return <div>Select a user</div>
  if (isPending) return <Skeleton />
  return <div>{data.name}</div>
}
```

**Dependent queries (waterfall is intentional):**

```typescript
function UserProjects({ userId }: { userId: string }) {
  // First query: get user
  const { data: user } = useQuery({
    queryKey: ['user', userId],
    queryFn: () => fetchUser(userId),
  })

  // Second query: depends on user's organizationId
  const { data: projects } = useQuery({
    queryKey: ['projects', user?.organizationId],
    queryFn: () => fetchProjects(user!.organizationId),
    enabled: !!user?.organizationId, // Wait for user data
  })
}
```

**Skip query based on feature flag:**

```typescript
const { data: experiments } = useQuery({
  queryKey: ['experiments'],
  queryFn: fetchExperiments,
  enabled: featureFlags.experimentsEnabled,
})
```

**Note:** When `enabled` is false:
- Query stays in `isPending` state
- No network request is made
- `data` remains undefined
