---
title: Show the post-mutation outcome immediately with automatic rollback on failure
impact: HIGH
impactDescription: 0ms perceived latency for mutations with automatic revert if the server rejects — no manual `if (success) keep else rollback` plumbing
tags: form, optimistic-ui, mutation-instant, auto-rollback
---

## Show the post-mutation outcome immediately with automatic rollback on failure

**Pattern intent:** when the user submits a mutation, the UI should reflect the intended result instantly. If the server rejects, the UI rolls back automatically. Manual snapshot/restore plumbing is brittle and rarely handles the corner cases (rapid re-submissions, race conditions, server-side reordering).

### Shapes to recognize

- An `onSubmit` that calls `setItems([...items, newItem])` *then* `await addItem(newItem)` and on error does `setItems(items)` (or similar manual rollback).
- A "shadow list" `useState` that mirrors the real list, manually merged with pending items, manually flushed on success — every concurrent submit creates a new merge edge case.
- A spinner shown over the entire list during mutation rather than just the affected row — manual snapshot would be too complex.
- "Pending" items stored in a Redux/Zustand slice with manual lifecycle reducers (`ADD_PENDING`, `RESOLVE`, `REJECT`).
- A child component that flickers from old → new → old → new during failed submissions — manual rollback applied at the wrong time.

The canonical resolution: `const [optimistic, addOptimistic] = useOptimistic(real, reducer)`. Call `addOptimistic(value)` from inside the form action *before* `await`-ing the server call. React reverts automatically when the action settles, regardless of outcome.

**Incorrect (waiting for server response):**

```typescript
'use client'

function TodoList({ todos }: { todos: Todo[] }) {
  async function handleAdd(formData: FormData) {
    const title = formData.get('title') as string
    await addTodo(title)  // UI waits for server
  }

  return (
    <form action={handleAdd}>
      <input name="title" />
      <button>Add</button>
      <ul>
        {todos.map(todo => <li key={todo.id}>{todo.title}</li>)}
      </ul>
    </form>
  )
}
// 200-500ms delay before new todo appears
```

**Correct (optimistic update):**

```typescript
'use client'

import { useOptimistic } from 'react'
import { addTodo } from './actions'

function TodoList({ todos }: { todos: Todo[] }) {
  const [optimisticTodos, addOptimisticTodo] = useOptimistic(
    todos,
    (state, newTodo: Todo) => [...state, newTodo]
  )

  async function handleAdd(formData: FormData) {
    const title = formData.get('title') as string

    addOptimisticTodo({
      id: crypto.randomUUID(),  // Temporary ID
      title,
      pending: true
    })

    await addTodo(title)  // Server confirms in background
  }

  return (
    <form action={handleAdd}>
      <input name="title" />
      <button>Add</button>
      <ul>
        {optimisticTodos.map(todo => (
          <li key={todo.id} style={{ opacity: todo.pending ? 0.5 : 1 }}>
            {todo.title}
          </li>
        ))}
      </ul>
    </form>
  )
}
// Todo appears instantly with pending style
```
