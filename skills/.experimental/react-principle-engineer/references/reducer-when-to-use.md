---
title: Use reducers for complex state logic
impact: MEDIUM
impactDescription: When state updates become complex with many handlers, consolidate them in a reducer for clarity
tags: [reducer, state, complexity, organization]
---

# Use Reducers for Complex State Logic

When a component has many state update handlers spread across event handlers, consider consolidating them in a reducer. This makes state updates predictable and testable.

## When to Use a Reducer

```tsx
// Signs you might need a reducer:
// 1. Multiple state variables that change together
// 2. Many event handlers that update state similarly
// 3. Complex update logic (add, remove, edit, reorder)
// 4. You want to test state logic separately
```

## Before: useState Scattered

```tsx
function TodoApp() {
  const [todos, setTodos] = useState<Todo[]>([]);

  function handleAdd(text: string) {
    setTodos([...todos, { id: Date.now(), text, done: false }]);
  }

  function handleChange(updatedTodo: Todo) {
    setTodos(todos.map(t => t.id === updatedTodo.id ? updatedTodo : t));
  }

  function handleDelete(id: number) {
    setTodos(todos.filter(t => t.id !== id));
  }

  function handleClearCompleted() {
    setTodos(todos.filter(t => !t.done));
  }

  function handleToggleAll() {
    const allDone = todos.every(t => t.done);
    setTodos(todos.map(t => ({ ...t, done: !allDone })));
  }

  // State logic is scattered across 5 different functions
}
```

## After: useReducer Consolidated

```tsx
type Action =
  | { type: 'added'; text: string }
  | { type: 'changed'; todo: Todo }
  | { type: 'deleted'; id: number }
  | { type: 'clearedCompleted' }
  | { type: 'toggledAll' };

function todosReducer(todos: Todo[], action: Action): Todo[] {
  switch (action.type) {
    case 'added':
      return [...todos, { id: Date.now(), text: action.text, done: false }];
    case 'changed':
      return todos.map(t => t.id === action.todo.id ? action.todo : t);
    case 'deleted':
      return todos.filter(t => t.id !== action.id);
    case 'clearedCompleted':
      return todos.filter(t => !t.done);
    case 'toggledAll': {
      const allDone = todos.every(t => t.done);
      return todos.map(t => ({ ...t, done: !allDone }));
    }
  }
}

function TodoApp() {
  const [todos, dispatch] = useReducer(todosReducer, []);

  // Event handlers become simple dispatch calls
  function handleAdd(text: string) {
    dispatch({ type: 'added', text });
  }

  function handleChange(todo: Todo) {
    dispatch({ type: 'changed', todo });
  }

  // All state logic is in one place: todosReducer
}
```

## Comparison

| Aspect | useState | useReducer |
|--------|----------|------------|
| Simple state | Better | Overkill |
| Multiple updates | Scattered | Consolidated |
| Complex logic | Hard to follow | Clear structure |
| Testing | Harder | Easy (pure function) |
| Code location | In component | Can be external file |

## Keep It Simple for Simple State

```tsx
// useState is fine for simple cases
function Counter() {
  const [count, setCount] = useState(0);

  return (
    <button onClick={() => setCount(c => c + 1)}>
      {count}
    </button>
  );
  // No need for reducer here!
}
```

## Key Principle

Reducers don't add functionality - they organize it. Use them when state logic becomes complex enough that consolidation improves readability and testability.
