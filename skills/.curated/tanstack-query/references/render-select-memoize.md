---
title: Memoize Select Functions
impact: MEDIUM
impactDescription: prevents repeated computation on every render
tags: render, select, memoization, useCallback, performance
---

## Memoize Select Functions

The `select` function runs on every render if passed inline. Memoize with `useCallback` or extract outside the component for stable reference.

**Incorrect (runs on every render):**

```typescript
function TodoCount() {
  const { data: count } = useQuery({
    queryKey: ['todos'],
    queryFn: fetchTodos,
    // Inline arrow function - new reference every render
    select: (todos) => todos.length,
  })

  return <span>{count} todos</span>
}
// select runs on EVERY render, even if todos didn't change
```

**Correct (stable function reference):**

```typescript
// Option 1: Extract outside component
const selectTodoCount = (todos: Todo[]) => todos.length

function TodoCount() {
  const { data: count } = useQuery({
    queryKey: ['todos'],
    queryFn: fetchTodos,
    select: selectTodoCount, // Stable reference
  })

  return <span>{count} todos</span>
}

// Option 2: useCallback (when closing over props)
function FilteredTodoCount({ minPriority }: { minPriority: number }) {
  const selectFiltered = useCallback(
    (todos: Todo[]) => todos.filter(t => t.priority >= minPriority).length,
    [minPriority] // Only recreate when minPriority changes
  )

  const { data: count } = useQuery({
    queryKey: ['todos'],
    queryFn: fetchTodos,
    select: selectFiltered,
  })

  return <span>{count} high priority todos</span>
}
```

**When inline is acceptable:**

```typescript
// Static filtering with no dependencies - consider extracting
const { data } = useQuery({
  queryKey: ['users'],
  queryFn: fetchUsers,
  select: (users) => users.filter(u => u.active), // Runs every render
})

// But if data changes rarely and component doesn't render often,
// the overhead is negligible
```

Reference: [Render Optimizations](https://tanstack.com/query/v5/docs/react/guides/render-optimizations)
