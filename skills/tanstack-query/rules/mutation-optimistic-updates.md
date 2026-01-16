---
title: Implement Optimistic Updates with Rollback
impact: HIGH
impactDescription: instant UI feedback, proper error recovery
tags: mutation, optimistic, rollback, onMutate, onError
---

## Implement Optimistic Updates with Rollback

Optimistic updates show changes immediately while the server processes. Without proper rollback in `onError`, failed mutations leave the UI in an inconsistent state.

**Incorrect (no rollback on error):**

```typescript
const mutation = useMutation({
  mutationFn: updateTodo,
  onMutate: async (newTodo) => {
    // Optimistically update
    queryClient.setQueryData(['todos'], (old: Todo[]) =>
      old.map(t => t.id === newTodo.id ? newTodo : t)
    )
  },
  onError: (error) => {
    // UI shows success, but server rejected it!
    toast.error('Failed to update')
    // User sees the "successful" update forever
  },
})
```

**Correct (full optimistic update pattern):**

```typescript
const mutation = useMutation({
  mutationFn: updateTodo,
  onMutate: async (newTodo) => {
    // 1. Cancel in-flight refetches (they'd overwrite our optimistic update)
    await queryClient.cancelQueries({ queryKey: ['todos'] })

    // 2. Snapshot current state for rollback
    const previousTodos = queryClient.getQueryData<Todo[]>(['todos'])

    // 3. Optimistically update cache
    queryClient.setQueryData(['todos'], (old: Todo[]) =>
      old.map(t => t.id === newTodo.id ? newTodo : t)
    )

    // 4. Return context for rollback
    return { previousTodos }
  },
  onError: (error, newTodo, context) => {
    // 5. Rollback on error
    if (context?.previousTodos) {
      queryClient.setQueryData(['todos'], context.previousTodos)
    }
    toast.error('Failed to update')
  },
  onSettled: () => {
    // 6. Always refetch to sync with server
    queryClient.invalidateQueries({ queryKey: ['todos'] })
  },
})
```

**Simplified v5 pattern (using mutation state):**

```typescript
const mutation = useMutation({
  mutationFn: updateTodo,
  onSettled: () => queryClient.invalidateQueries({ queryKey: ['todos'] }),
})

// Use mutation.variables for optimistic display
function TodoItem({ todo }: { todo: Todo }) {
  const optimisticTodo = mutation.isPending && mutation.variables?.id === todo.id
    ? mutation.variables
    : todo

  return <div>{optimisticTodo.title}</div>
}
```
