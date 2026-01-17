---
title: Invalidate in onSettled, Not onSuccess
impact: HIGH
impactDescription: ensures cache sync after errors too
tags: mutation, invalidation, onSettled, onSuccess, consistency
---

## Invalidate in onSettled, Not onSuccess

Invalidating only in `onSuccess` leaves the cache inconsistent after failed mutations. Use `onSettled` to ensure cache invalidation regardless of success or failure.

**Incorrect (invalidate in onSuccess only):**

```typescript
const mutation = useMutation({
  mutationFn: createTodo,
  onSuccess: () => {
    // Only runs on success
    queryClient.invalidateQueries({ queryKey: ['todos'] })
  },
})

// If mutation fails after optimistic update:
// 1. onError restores old state
// 2. But server might have partial state
// 3. onSuccess never runs, no refetch
// 4. Client and server are out of sync!
```

**Correct (invalidate in onSettled):**

```typescript
const mutation = useMutation({
  mutationFn: createTodo,
  onMutate: async (newTodo) => {
    await queryClient.cancelQueries({ queryKey: ['todos'] })
    const previous = queryClient.getQueryData(['todos'])
    queryClient.setQueryData(['todos'], (old: Todo[]) => [...old, newTodo])
    return { previous }
  },
  onError: (err, newTodo, context) => {
    queryClient.setQueryData(['todos'], context?.previous)
  },
  onSettled: () => {
    // Runs after BOTH success AND error
    // Ensures cache matches server state
    queryClient.invalidateQueries({ queryKey: ['todos'] })
  },
})
```

**When to use onSuccess specifically:**

```typescript
const mutation = useMutation({
  mutationFn: createTodo,
  onSuccess: (data) => {
    // Use response data for something specific
    toast.success(`Created: ${data.title}`)
    router.push(`/todos/${data.id}`)
  },
  onError: (error) => {
    toast.error(error.message)
  },
  onSettled: () => {
    // Always invalidate here
    queryClient.invalidateQueries({ queryKey: ['todos'] })
  },
})
```
