---
title: Extract reducers outside components
impact: LOW
impactDescription: Define reducers outside the component for cleaner code, easier testing, and potential reuse
tags: [reducer, organization, testing, reuse, modules]
---

# Extract Reducers Outside Components

Define reducer functions outside your component, typically in the same file or a separate module. This improves organization and testability.

## Before: Reducer Inside Component

```tsx
// Less ideal: reducer defined inside component
function TodoApp() {
  function todosReducer(todos: Todo[], action: Action): Todo[] {
    switch (action.type) {
      case 'added':
        return [...todos, { id: Date.now(), text: action.text, done: false }];
      case 'deleted':
        return todos.filter(t => t.id !== action.id);
      default:
        throw new Error('Unknown action');
    }
  }

  const [todos, dispatch] = useReducer(todosReducer, []);

  return <TodoList todos={todos} dispatch={dispatch} />;
}
```

## After: Reducer Outside Component

```tsx
// Better: reducer defined outside, near component
type Action =
  | { type: 'added'; text: string }
  | { type: 'deleted'; id: number };

function todosReducer(todos: Todo[], action: Action): Todo[] {
  switch (action.type) {
    case 'added':
      return [...todos, { id: Date.now(), text: action.text, done: false }];
    case 'deleted':
      return todos.filter(t => t.id !== action.id);
    default:
      throw new Error('Unknown action');
  }
}

function TodoApp() {
  const [todos, dispatch] = useReducer(todosReducer, []);
  return <TodoList todos={todos} dispatch={dispatch} />;
}
```

## Separate File for Complex Reducers

```tsx
// todosReducer.ts
export type Todo = {
  id: number;
  text: string;
  done: boolean;
};

export type Action =
  | { type: 'added'; text: string }
  | { type: 'toggled'; id: number }
  | { type: 'deleted'; id: number };

export const initialTodos: Todo[] = [];

export function todosReducer(todos: Todo[], action: Action): Todo[] {
  switch (action.type) {
    case 'added':
      return [...todos, { id: Date.now(), text: action.text, done: false }];
    case 'toggled':
      return todos.map(t =>
        t.id === action.id ? { ...t, done: !t.done } : t
      );
    case 'deleted':
      return todos.filter(t => t.id !== action.id);
    default:
      throw new Error('Unknown action');
  }
}
```

```tsx
// TodoApp.tsx
import { useReducer } from 'react';
import { todosReducer, initialTodos } from './todosReducer';

function TodoApp() {
  const [todos, dispatch] = useReducer(todosReducer, initialTodos);
  return <TodoList todos={todos} dispatch={dispatch} />;
}
```

## Benefits of Extraction

### 1. Easier Testing

```tsx
// todosReducer.test.ts
import { todosReducer, Todo, Action } from './todosReducer';

describe('todosReducer', () => {
  test('adds a todo', () => {
    const before: Todo[] = [];
    const action: Action = { type: 'added', text: 'Test' };

    const after = todosReducer(before, action);

    expect(after).toHaveLength(1);
    expect(after[0].text).toBe('Test');
  });

  test('toggles a todo', () => {
    const before: Todo[] = [{ id: 1, text: 'Test', done: false }];
    const action: Action = { type: 'toggled', id: 1 };

    const after = todosReducer(before, action);

    expect(after[0].done).toBe(true);
  });
});
// No React rendering needed - just pure function testing
```

### 2. Reusability

```tsx
// Same reducer for different components
import { todosReducer, initialTodos } from './todosReducer';

function TodoApp() {
  const [todos, dispatch] = useReducer(todosReducer, initialTodos);
  return <DesktopTodoList todos={todos} dispatch={dispatch} />;
}

function MobileTodoApp() {
  const [todos, dispatch] = useReducer(todosReducer, initialTodos);
  return <MobileTodoList todos={todos} dispatch={dispatch} />;
}
```

### 3. Cleaner Components

```tsx
// Component focuses on UI, not state logic
function TodoApp() {
  const [todos, dispatch] = useReducer(todosReducer, initialTodos);

  return (
    <div>
      <AddTodoForm onAdd={text => dispatch({ type: 'added', text })} />
      <TodoList
        todos={todos}
        onToggle={id => dispatch({ type: 'toggled', id })}
        onDelete={id => dispatch({ type: 'deleted', id })}
      />
    </div>
  );
}
// No switch statement cluttering the component
```

## Key Principle

Extracting reducers separates state logic from UI rendering. The component decides when to dispatch; the reducer (external, pure, testable) decides how state changes.
