---
title: Avoid Parallel Mutations on Same Data
impact: MEDIUM
impactDescription: prevents race conditions and cache corruption
tags: mutation, parallel, race-condition, isPending
---

## Avoid Parallel Mutations on Same Data

Multiple parallel mutations on the same resource cause race conditions—the last response wins regardless of which mutation was "correct." Disable UI or use mutation state to prevent this.

**Incorrect (allow parallel mutations):**

```typescript
function TodoItem({ todo }: { todo: Todo }) {
  const mutation = useMutation({
    mutationFn: updateTodo,
    onSettled: () => queryClient.invalidateQueries({ queryKey: ['todos'] }),
  })

  return (
    <div>
      <input
        value={todo.title}
        onChange={(e) => mutation.mutate({ ...todo, title: e.target.value })}
        // User types fast: "H" "He" "Hel" "Hell" "Hello"
        // 5 parallel mutations, responses arrive out of order
        // Final state might be "Hel" instead of "Hello"!
      />
    </div>
  )
}
```

**Correct (debounce or disable during mutation):**

```typescript
function TodoItem({ todo }: { todo: Todo }) {
  const [title, setTitle] = useState(todo.title)
  const mutation = useMutation({
    mutationFn: updateTodo,
    onSettled: () => queryClient.invalidateQueries({ queryKey: ['todos'] }),
  })

  // Debounce the mutation
  const debouncedSave = useDebouncedCallback((newTitle: string) => {
    mutation.mutate({ ...todo, title: newTitle })
  }, 500)

  return (
    <input
      value={title}
      onChange={(e) => {
        setTitle(e.target.value)
        debouncedSave(e.target.value)
      }}
    />
  )
}
```

**Alternative: disable during mutation:**

```typescript
function SaveButton({ todo }: { todo: Todo }) {
  const mutation = useMutation({ mutationFn: updateTodo })

  return (
    <button
      onClick={() => mutation.mutate(todo)}
      disabled={mutation.isPending} // Prevent double-click
    >
      {mutation.isPending ? 'Saving...' : 'Save'}
    </button>
  )
}
```
