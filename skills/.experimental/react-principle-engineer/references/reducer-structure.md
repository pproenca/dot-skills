---
title: Structure reducers with switch and case blocks
impact: LOW
impactDescription: Use switch statements with braced case blocks; always handle unknown actions
tags: [reducer, structure, switch, patterns, organization]
---

# Structure Reducers with Switch and Case Blocks

The conventional way to write reducers is with a switch statement. Wrap each case in braces, always return, and throw on unknown actions.

## Basic Structure

```tsx
function reducer(state: State, action: Action): State {
  switch (action.type) {
    case 'first_action': {
      // Braces create a block scope for local variables
      const newValue = calculateSomething(action.payload);
      return { ...state, value: newValue };
    }

    case 'second_action': {
      return { ...state, other: action.data };
    }

    default: {
      // Throw on unknown action to catch bugs
      throw new Error(`Unknown action: ${action.type}`);
    }
  }
}
```

## Why Braces Around Cases

```tsx
// WITHOUT braces: variables leak across cases
function badReducer(state: State, action: Action) {
  switch (action.type) {
    case 'first':
      const x = 1;  // x is accessible in 'second' case!
      return state;

    case 'second':
      const x = 2;  // ERROR: x already declared
      return state;
  }
}

// WITH braces: each case has its own scope
function goodReducer(state: State, action: Action) {
  switch (action.type) {
    case 'first': {
      const x = 1;  // Scoped to this case
      return state;
    }

    case 'second': {
      const x = 2;  // Separate variable, no conflict
      return state;
    }
  }
}
```

## Always Return or Throw

```tsx
function reducer(state: State, action: Action): State {
  switch (action.type) {
    case 'increment': {
      return { ...state, count: state.count + 1 };
      // Always return the new state
    }

    case 'decrement': {
      return { ...state, count: state.count - 1 };
      // Return at the end of each case
    }

    case 'reset': {
      return initialState;
      // Can return a completely new state
    }

    default: {
      // TypeScript will catch missing cases with proper union types
      // Throw to catch runtime errors
      throw new Error(`Unknown action type: ${(action as any).type}`);
    }
  }
}
```

## TypeScript Exhaustiveness

```tsx
// Define action type as union
type Action =
  | { type: 'increment' }
  | { type: 'decrement' }
  | { type: 'reset' };

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case 'increment':
      return { ...state, count: state.count + 1 };

    case 'decrement':
      return { ...state, count: state.count - 1 };

    case 'reset':
      return initialState;

    default: {
      // TypeScript knows this is unreachable if all cases handled
      const exhaustiveCheck: never = action;
      throw new Error(`Unhandled action: ${exhaustiveCheck}`);
    }
  }
}
// Adding a new action type will cause TypeScript error until handled
```

## Alternative: If/Else (Works Too)

```tsx
// If you prefer if/else, that's fine too
function reducer(state: State, action: Action): State {
  if (action.type === 'increment') {
    return { ...state, count: state.count + 1 };
  }

  if (action.type === 'decrement') {
    return { ...state, count: state.count - 1 };
  }

  if (action.type === 'reset') {
    return initialState;
  }

  throw new Error(`Unknown action: ${action.type}`);
}
```

## Organizing Large Reducers

```tsx
// For large reducers, extract helper functions
function todosReducer(state: TodoState, action: Action): TodoState {
  switch (action.type) {
    case 'todo_added': {
      return addTodo(state, action.text);
    }

    case 'todo_toggled': {
      return toggleTodo(state, action.id);
    }

    case 'todo_deleted': {
      return deleteTodo(state, action.id);
    }

    default: {
      throw new Error(`Unknown action: ${action.type}`);
    }
  }
}

// Helper functions (also pure)
function addTodo(state: TodoState, text: string): TodoState {
  return {
    ...state,
    todos: [...state.todos, { id: Date.now(), text, done: false }],
  };
}

function toggleTodo(state: TodoState, id: number): TodoState {
  return {
    ...state,
    todos: state.todos.map(t =>
      t.id === id ? { ...t, done: !t.done } : t
    ),
  };
}
```

## Key Principle

Consistent reducer structure makes state changes predictable and scannable. Use braces for scope, always return, and throw on unknown actions to catch bugs early.
