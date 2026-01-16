---
title: Cancel Queries Before Optimistic Updates
impact: HIGH
impactDescription: prevents race conditions, preserves optimistic state
tags: mutation, cancelQueries, race-condition, optimistic
---

## Cancel Queries Before Optimistic Updates

In-flight refetches can overwrite optimistic updates with stale server data. Always cancel pending queries before updating the cache optimistically.

**Incorrect (race condition possible):**

```typescript
const mutation = useMutation({
  mutationFn: updateTodo,
  onMutate: async (newTodo) => {
    // Optimistically update without canceling
    queryClient.setQueryData(['todos'], (old: Todo[]) =>
      old.map(t => t.id === newTodo.id ? newTodo : t)
    )
    // Meanwhile, a refetch completes and overwrites our optimistic update!
  },
})
```

**Timeline of the bug:**
```
t=0ms: User clicks save, mutation starts
t=0ms: Optimistic update shows new title
t=5ms: Background refetch (started earlier) completes
t=5ms: Old data overwrites optimistic update!
t=100ms: Mutation succeeds, but user saw flash of old data
```

**Correct (cancel before update):**

```typescript
const mutation = useMutation({
  mutationFn: updateTodo,
  onMutate: async (newTodo) => {
    // Cancel any in-flight queries for this data
    await queryClient.cancelQueries({ queryKey: ['todos'] })

    // Now safe to update optimistically
    const previous = queryClient.getQueryData(['todos'])
    queryClient.setQueryData(['todos'], (old: Todo[]) =>
      old.map(t => t.id === newTodo.id ? newTodo : t)
    )

    return { previous }
  },
  onError: (err, newTodo, context) => {
    queryClient.setQueryData(['todos'], context?.previous)
  },
  onSettled: () => {
    queryClient.invalidateQueries({ queryKey: ['todos'] })
  },
})
```

**Cancel specific queries for better precision:**

```typescript
onMutate: async (newTodo) => {
  // Only cancel the specific item's query, not all todos
  await queryClient.cancelQueries({
    queryKey: ['todos', 'detail', newTodo.id],
  })
  // ... rest of optimistic update
}
```
