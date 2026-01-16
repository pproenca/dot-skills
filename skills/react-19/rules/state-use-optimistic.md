---
title: Use useOptimistic for Instant Feedback
impact: MEDIUM-HIGH
impactDescription: 0ms perceived latency for mutations (instant feedback)
tags: state, useOptimistic, optimistic-updates, ux
---

## Use useOptimistic for Instant Feedback

The `useOptimistic` hook shows immediate UI changes while async operations complete. Users see instant feedback instead of waiting for server responses.

**Incorrect (user waits for response):**

```tsx
function TodoList({ todos, onAdd }: Props) {
  const [isPending, startTransition] = useTransition()

  const handleAdd = async (formData: FormData) => {
    const title = formData.get('title') as string
    startTransition(async () => {
      await addTodo(title)  // User waits 200-500ms
    })
  }

  return (
    <div>
      <form action={handleAdd}>
        <input name="title" />
        <button disabled={isPending}>
          {isPending ? 'Adding...' : 'Add'}
        </button>
      </form>
      <ul>
        {todos.map(todo => <TodoItem key={todo.id} todo={todo} />)}
      </ul>
    </div>
  )
}
```

**Correct (instant visual feedback):**

```tsx
function TodoList({ todos, onAdd }: Props) {
  const [optimisticTodos, addOptimisticTodo] = useOptimistic(
    todos,
    (currentTodos, newTitle: string) => [
      ...currentTodos,
      { id: crypto.randomUUID(), title: newTitle, pending: true }
    ]
  )

  const handleAdd = async (formData: FormData) => {
    const title = formData.get('title') as string
    addOptimisticTodo(title)  // Instantly shows in UI
    await addTodo(title)  // Server confirms in background
  }

  return (
    <div>
      <form action={handleAdd}>
        <input name="title" />
        <button>Add</button>
      </form>
      <ul>
        {optimisticTodos.map(todo => (
          <TodoItem
            key={todo.id}
            todo={todo}
            className={todo.pending ? 'opacity-50' : ''}
          />
        ))}
      </ul>
    </div>
  )
}
```

**Benefits:**
- Zero perceived latency for user actions
- Automatic rollback on failure
- Visual distinction for pending items

Reference: [useOptimistic](https://react.dev/reference/react/useOptimistic)
