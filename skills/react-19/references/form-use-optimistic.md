---
title: Use useOptimistic for Instant UI Feedback
impact: HIGH
impactDescription: instant perceived response, auto-rollback on failure
tags: form, useOptimistic, optimistic-ui, mutation
---

## Use useOptimistic for Instant UI Feedback

`useOptimistic` shows a temporary state immediately while the actual action runs in the background. If it fails, React automatically reverts.

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
