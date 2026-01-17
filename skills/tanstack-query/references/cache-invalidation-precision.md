---
title: Invalidate with Precision
impact: HIGH
impactDescription: prevents over-invalidation cascade, improves performance
tags: cache, invalidation, mutations, precision
---

## Invalidate with Precision

Broad invalidation (`queryClient.invalidateQueries()` with no filter) refetches everything, causing unnecessary network traffic. Use hierarchical keys to invalidate only affected queries.

**Incorrect (nuclear invalidation):**

```typescript
const mutation = useMutation({
  mutationFn: updateUser,
  onSuccess: () => {
    // Invalidates EVERY query in the cache!
    queryClient.invalidateQueries()
  },
})

// Also bad - too broad for a single user update
const mutation = useMutation({
  mutationFn: updateUser,
  onSuccess: () => {
    // Refetches all user lists, all user details - wasteful
    queryClient.invalidateQueries({ queryKey: ['users'] })
  },
})
```

**Correct (surgical invalidation):**

```typescript
const mutation = useMutation({
  mutationFn: (data: { userId: string; updates: UserUpdate }) =>
    updateUser(data.userId, data.updates),
  onSuccess: (_, variables) => {
    // Only invalidate the specific user detail
    queryClient.invalidateQueries({
      queryKey: ['users', 'detail', variables.userId],
    })
    // And user lists (they contain this user's summary)
    queryClient.invalidateQueries({
      queryKey: ['users', 'list'],
    })
  },
})
```

**Even better - update cache directly when possible:**

```typescript
const mutation = useMutation({
  mutationFn: updateUser,
  onSuccess: (updatedUser) => {
    // Update detail cache directly - no refetch needed
    queryClient.setQueryData(
      ['users', 'detail', updatedUser.id],
      updatedUser
    )
    // Only invalidate lists (need refetch for sorting/filtering)
    queryClient.invalidateQueries({ queryKey: ['users', 'list'] })
  },
})
```

**Use exact match when needed:**

```typescript
// Invalidate ONLY ['users', 'list', { status: 'active' }]
// Not ['users', 'list'] or ['users', 'list', { status: 'inactive' }]
queryClient.invalidateQueries({
  queryKey: ['users', 'list', { status: 'active' }],
  exact: true,
})
```
