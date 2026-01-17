---
title: Use setQueryData for Immediate Cache Updates
impact: MEDIUM
impactDescription: instant UI updates without refetch roundtrip
tags: mutation, setQueryData, cache, response
---

## Use setQueryData for Immediate Cache Updates

When mutation responses contain the updated data, use `setQueryData` to update the cache directly instead of invalidating and refetching.

**Incorrect (always invalidate):**

```typescript
const mutation = useMutation({
  mutationFn: updateUser,
  onSuccess: () => {
    // Triggers a refetch - extra roundtrip!
    queryClient.invalidateQueries({ queryKey: ['user', userId] })
  },
})
```

**Correct (use response data):**

```typescript
const mutation = useMutation({
  mutationFn: updateUser,
  onSuccess: (updatedUser) => {
    // Update cache directly with response
    queryClient.setQueryData(['user', updatedUser.id], updatedUser)

    // Only invalidate related queries that might be affected
    queryClient.invalidateQueries({ queryKey: ['users', 'list'] })
  },
})
```

**Update nested cache entries:**

```typescript
const mutation = useMutation({
  mutationFn: (data: { todoId: string; completed: boolean }) =>
    updateTodo(data.todoId, { completed: data.completed }),
  onSuccess: (updatedTodo) => {
    // Update the detail cache
    queryClient.setQueryData(['todos', 'detail', updatedTodo.id], updatedTodo)

    // Update the todo within list caches
    queryClient.setQueriesData(
      { queryKey: ['todos', 'list'] },
      (old: Todo[] | undefined) =>
        old?.map(t => t.id === updatedTodo.id ? updatedTodo : t)
    )
  },
})
```

**When to invalidate vs setQueryData:**

| Scenario | Use |
|----------|-----|
| API returns full updated entity | `setQueryData` |
| API returns partial data | `invalidateQueries` |
| Update affects list ordering/filtering | `invalidateQueries` |
| Delete operation | Both (remove + invalidate) |
| Create operation | Both (add + invalidate for sorting) |
