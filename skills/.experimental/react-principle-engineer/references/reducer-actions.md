---
title: Actions describe what happened, not what to do
impact: MEDIUM
impactDescription: Actions represent user intent or events; the reducer decides how to update state
tags: [reducer, actions, intent, events, patterns]
---

# Actions Describe What Happened, Not What to Do

Actions should describe the event or user intent, not the state mutation. The reducer is responsible for deciding how to respond.

## Why This Matters

Descriptive actions:
- Capture user intent clearly
- Enable logging and debugging
- Make the event history readable
- Keep components decoupled from state logic

## Incorrect: Actions as Commands

```tsx
// Problem: Actions tell reducer what to do (imperative)
dispatch({ type: 'SET_TODOS', todos: newTodos });
dispatch({ type: 'PUSH_TODO', todo: newTodo });
dispatch({ type: 'FILTER_DONE' });

// This is just setState with extra steps
// Component still knows the implementation
```

## Correct: Actions as Events

```tsx
// Solution: Actions describe what happened (declarative)
dispatch({ type: 'added_todo', text: 'Learn React' });
dispatch({ type: 'toggled_todo', id: 123 });
dispatch({ type: 'deleted_todo', id: 456 });
dispatch({ type: 'cleared_completed' });

// Component says what the user did
// Reducer decides how to respond
```

## Action Naming Conventions

```tsx
// Use past tense to describe what happened
type Action =
  | { type: 'todo_added'; text: string }
  | { type: 'todo_toggled'; id: number }
  | { type: 'todo_deleted'; id: number }
  | { type: 'filter_changed'; filter: Filter }
  | { type: 'all_completed' }
  | { type: 'completed_cleared' };

// Or use snake_case with past tense
// 'added', 'changed', 'deleted', 'toggled'
```

## Complete Example

```tsx
// Actions describe what the user did
type Action =
  | { type: 'contact_selected'; contactId: string }
  | { type: 'message_typed'; text: string }
  | { type: 'message_sent' }
  | { type: 'conversation_started'; contactId: string };

function messengerReducer(state: MessengerState, action: Action) {
  switch (action.type) {
    case 'contact_selected':
      return {
        ...state,
        selectedContactId: action.contactId,
        draft: '',  // Reducer decides to clear draft
      };

    case 'message_typed':
      return {
        ...state,
        draft: action.text,
      };

    case 'message_sent':
      return {
        ...state,
        messages: [
          ...state.messages,
          {
            id: Date.now(),
            contactId: state.selectedContactId,
            text: state.draft,
          },
        ],
        draft: '',  // Reducer decides to clear draft
      };

    default:
      return state;
  }
}

// Component dispatches user actions
function Messenger() {
  const [state, dispatch] = useReducer(messengerReducer, initialState);

  function handleContactClick(contactId: string) {
    dispatch({ type: 'contact_selected', contactId });
  }

  function handleSend() {
    dispatch({ type: 'message_sent' });
    // Component doesn't know that draft gets cleared
  }
}
```

## Benefits of Descriptive Actions

```tsx
// 1. Readable action history
// [
//   { type: 'contact_selected', contactId: 'alice' },
//   { type: 'message_typed', text: 'Hello!' },
//   { type: 'message_sent' },
//   { type: 'contact_selected', contactId: 'bob' },
// ]
// You can understand what the user did!

// 2. Easy to add features without changing components
// Want to log analytics? Add it to reducer
// Want to save to localStorage? Add it to reducer
// Component code stays the same

// 3. Time-travel debugging
// Play back actions to reproduce bugs
```

## Key Principle

Think of actions as entries in a user's activity log: "User added todo", "User toggled item", "User selected contact". The reducer reads this log and decides how state should change.
