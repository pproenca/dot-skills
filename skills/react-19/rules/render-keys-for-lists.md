---
title: Use Stable Keys for List Rendering
impact: MEDIUM
impactDescription: prevents unnecessary DOM recreation and state loss
tags: render, keys, lists, reconciliation
---

## Use Stable Keys for List Rendering

Keys help React identify which items changed. Unstable keys (like array indices or random values) cause unnecessary DOM recreation, lost component state, and poor performance.

**Incorrect (index as key):**

```tsx
function TodoList({ todos }: { todos: Todo[] }) {
  return (
    <ul>
      {todos.map((todo, index) => (
        <TodoItem key={index} todo={todo} />  // Key changes when items reorder
      ))}
    </ul>
  )
}
// Inserting item at index 0 recreates ALL items
// Input focus and local state is lost
```

**Incorrect (random key):**

```tsx
function TodoList({ todos }: { todos: Todo[] }) {
  return (
    <ul>
      {todos.map(todo => (
        <TodoItem key={Math.random()} todo={todo} />  // New key every render!
      ))}
    </ul>
  )
}
// Every render recreates ALL DOM nodes
```

**Correct (stable unique identifier):**

```tsx
function TodoList({ todos }: { todos: Todo[] }) {
  return (
    <ul>
      {todos.map(todo => (
        <TodoItem key={todo.id} todo={todo} />  // Stable across renders
      ))}
    </ul>
  )
}
// Only changed items update, state preserved
```

**When index keys are acceptable:**
- Static lists that never reorder
- Lists that never add/remove items
- Items have no local state or effects

Reference: [Rendering Lists](https://react.dev/learn/rendering-lists#keeping-list-items-in-order-with-key)
