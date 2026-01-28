---
title: Stabilize Event Handlers with useCallback
impact: MEDIUM
impactDescription: prevents child re-renders from handler recreation
tags: render, useCallback, handlers, optimization, hooks
---

## Stabilize Event Handlers with useCallback

Without useCallback, event handlers are recreated on every render, breaking memo() on children.

**Incorrect (new function reference every render):**

```tsx
function TodoList({ todos, onComplete, onDelete }) {
  return (
    <FlatList
      data={todos}
      renderItem={({ item }) => (
        <TodoItem
          todo={item}
          // New function on every render - breaks memo
          onComplete={() => onComplete(item.id)}
          onDelete={() => onDelete(item.id)}
        />
      )}
    />
  )
}

// memo is useless because callbacks change every render
const TodoItem = memo(function TodoItem({ todo, onComplete, onDelete }) {
  return (
    <View>
      <Text>{todo.text}</Text>
      <Button onPress={onComplete} title="Complete" />
      <Button onPress={onDelete} title="Delete" />
    </View>
  )
})
```

**Correct (stable callbacks):**

```tsx
function TodoList({ todos, onComplete, onDelete }) {
  const renderItem = useCallback(({ item }) => (
    <TodoItem
      todo={item}
      onComplete={onComplete}
      onDelete={onDelete}
    />
  ), [onComplete, onDelete])

  return (
    <FlatList
      data={todos}
      renderItem={renderItem}
    />
  )
}

// Item creates its own stable handlers
const TodoItem = memo(function TodoItem({ todo, onComplete, onDelete }) {
  const handleComplete = useCallback(() => {
    onComplete(todo.id)
  }, [todo.id, onComplete])

  const handleDelete = useCallback(() => {
    onDelete(todo.id)
  }, [todo.id, onDelete])

  return (
    <View>
      <Text>{todo.text}</Text>
      <Button onPress={handleComplete} title="Complete" />
      <Button onPress={handleDelete} title="Delete" />
    </View>
  )
})
```

**Functional setState removes dependencies:**

```tsx
function Counter() {
  const [count, setCount] = useState(0)

  // Bad: depends on count, recreated when count changes
  const increment = useCallback(() => {
    setCount(count + 1)
  }, [count])

  // Good: no dependencies, never recreated
  const increment = useCallback(() => {
    setCount(c => c + 1)
  }, [])

  return (
    <View>
      <Text>{count}</Text>
      <MemoizedButton onPress={increment} title="+" />
    </View>
  )
}
```

**Pass ID instead of handler:**

```tsx
// Alternative pattern: pass ID, handle in parent
function TodoList({ todos }) {
  const handleAction = useCallback((action, id) => {
    if (action === 'complete') completeTodo(id)
    if (action === 'delete') deleteTodo(id)
  }, [])

  return (
    <FlatList
      data={todos}
      renderItem={({ item }) => (
        <TodoItem todo={item} onAction={handleAction} />
      )}
    />
  )
}

const TodoItem = memo(function TodoItem({ todo, onAction }) {
  return (
    <View>
      <Text>{todo.text}</Text>
      <Button onPress={() => onAction('complete', todo.id)} title="✓" />
      <Button onPress={() => onAction('delete', todo.id)} title="✕" />
    </View>
  )
})
```

**When to use useCallback:**
- Handlers passed to memoized children
- Handlers in useEffect dependencies
- Handlers passed through context

Reference: [React useCallback Documentation](https://react.dev/reference/react/useCallback)
