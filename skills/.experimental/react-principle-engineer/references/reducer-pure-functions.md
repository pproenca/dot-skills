---
title: Reducers must be pure functions
impact: HIGH
impactDescription: Reducers receive state and action, return new state - no mutations, no side effects
tags: [reducer, purity, functions, mutations, side-effects]
---

# Reducers Must Be Pure Functions

A reducer takes the current state and an action, and returns the next state. It must not mutate the state, make API calls, or have any side effects.

## The Reducer Contract

```tsx
// Reducers follow this signature:
function reducer(state: State, action: Action): State {
  // 1. Read current state and action
  // 2. Calculate new state
  // 3. Return new state object
  // NO mutations, NO side effects
}
```

## Correct: Pure Reducer

```tsx
function todosReducer(state: Todo[], action: Action): Todo[] {
  switch (action.type) {
    case 'added':
      // Return NEW array with new item
      return [
        ...state,
        { id: action.id, text: action.text, done: false },
      ];

    case 'toggled':
      // Return NEW array with NEW item objects
      return state.map(todo =>
        todo.id === action.id
          ? { ...todo, done: !todo.done }  // New object
          : todo
      );

    case 'deleted':
      // Return NEW filtered array
      return state.filter(todo => todo.id !== action.id);

    default:
      return state;
  }
}
```

## Incorrect: Mutating State

```tsx
// Problem: Mutating the state array
function badReducer(state: Todo[], action: Action): Todo[] {
  switch (action.type) {
    case 'added':
      state.push({ id: action.id, text: action.text });  // MUTATION!
      return state;  // Same reference!

    case 'toggled':
      const todo = state.find(t => t.id === action.id);
      if (todo) {
        todo.done = !todo.done;  // MUTATION!
      }
      return state;

    default:
      return state;
  }
}
// React won't detect changes (same reference)
// StrictMode will expose bugs
```

## Incorrect: Side Effects in Reducer

```tsx
// Problem: Side effects in reducer
function badReducer(state: State, action: Action): State {
  switch (action.type) {
    case 'saved':
      // WRONG: API call in reducer!
      fetch('/api/save', { method: 'POST', body: JSON.stringify(state) });

      // WRONG: Logging side effect!
      console.log('Saved!');

      // WRONG: localStorage access!
      localStorage.setItem('state', JSON.stringify(state));

      return state;
  }
}
```

## Correct: Side Effects Outside Reducer

```tsx
// Solution: Side effects in component/middleware
function Component() {
  const [state, dispatch] = useReducer(reducer, initialState);

  async function handleSave() {
    // Side effect in event handler
    await fetch('/api/save', { body: JSON.stringify(state) });

    // Then dispatch action
    dispatch({ type: 'saved' });
  }

  // Or use effect for reactions
  useEffect(() => {
    localStorage.setItem('state', JSON.stringify(state));
  }, [state]);
}
```

## Using Immer for Easier Immutability

```tsx
import { useImmerReducer } from 'use-immer';

// With Immer, you can "mutate" the draft
function todosReducer(draft: Todo[], action: Action) {
  switch (action.type) {
    case 'added':
      draft.push({ id: action.id, text: action.text, done: false });
      break;  // No return needed with Immer

    case 'toggled':
      const todo = draft.find(t => t.id === action.id);
      if (todo) {
        todo.done = !todo.done;  // "Mutation" is safe with Immer
      }
      break;

    case 'deleted':
      const index = draft.findIndex(t => t.id === action.id);
      if (index !== -1) {
        draft.splice(index, 1);  // "Mutation" is safe with Immer
      }
      break;
  }
}

function TodoApp() {
  const [todos, dispatch] = useImmerReducer(todosReducer, []);
}
// Immer produces immutable updates under the hood
```

## Testing Pure Reducers

```tsx
// Pure reducers are trivial to test
describe('todosReducer', () => {
  test('adds a todo', () => {
    const before: Todo[] = [];
    const action = { type: 'added' as const, id: 1, text: 'Test' };

    const after = todosReducer(before, action);

    expect(after).toHaveLength(1);
    expect(after[0]).toEqual({ id: 1, text: 'Test', done: false });
    expect(before).toHaveLength(0);  // Original unchanged
  });

  test('toggles a todo', () => {
    const before = [{ id: 1, text: 'Test', done: false }];
    const action = { type: 'toggled' as const, id: 1 };

    const after = todosReducer(before, action);

    expect(after[0].done).toBe(true);
    expect(before[0].done).toBe(false);  // Original unchanged
  });
});
```

## Key Principle

`newState = reducer(oldState, action)`. The reducer is a pure function that describes how actions transform state. Keep it pure for predictability, testability, and React compatibility.
