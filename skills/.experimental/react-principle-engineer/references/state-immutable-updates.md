---
title: Update state immutably
impact: HIGH
impactDescription: Mutating state directly bypasses React's change detection and causes rendering bugs
tags: [state, immutability, updates, spread, copy]
---

# Update State Immutably

Never mutate state directly. Create new objects or arrays with the changes you want, then pass them to the setter function.

## Why This Matters

React uses reference equality to detect changes:
- Mutating keeps the same reference
- React doesn't know anything changed
- Component doesn't re-render
- UI becomes stale

**Incorrect (anti-pattern):**

```tsx
// Problem: Mutating state directly
function Counter() {
  const [person, setPerson] = useState({ name: 'Alice', age: 25 });

  function handleBirthday() {
    // WRONG: Mutating the existing object
    person.age += 1;
    setPerson(person);  // Same reference - React won't re-render!
  }

  return (
    <div>
      <p>{person.name} is {person.age}</p>
      <button onClick={handleBirthday}>Birthday!</button>
    </div>
  );
}
```

**Correct (recommended):**

```tsx
// Solution: Create a new object with changes
function Counter() {
  const [person, setPerson] = useState({ name: 'Alice', age: 25 });

  function handleBirthday() {
    // Create new object with updated property
    setPerson({
      ...person,  // Copy existing properties
      age: person.age + 1,  // Override the one that changed
    });
  }

  return (
    <div>
      <p>{person.name} is {person.age}</p>
      <button onClick={handleBirthday}>Birthday!</button>
    </div>
  );
}
```

## Array Updates

```tsx
// Problem: Mutating array methods
function TodoList() {
  const [todos, setTodos] = useState<string[]>(['Buy milk']);

  function addTodo(text: string) {
    todos.push(text);  // WRONG: Mutates array
    setTodos(todos);   // Same reference
  }

  function removeTodo(index: number) {
    todos.splice(index, 1);  // WRONG: Mutates array
    setTodos(todos);
  }

  function sortTodos() {
    todos.sort();  // WRONG: Mutates array
    setTodos(todos);
  }
}
```

## Correct Array Updates

```tsx
// Solution: Non-mutating array methods
function TodoList() {
  const [todos, setTodos] = useState<string[]>(['Buy milk']);

  // Adding: spread + new item
  function addTodo(text: string) {
    setTodos([...todos, text]);
  }

  // Removing: filter
  function removeTodo(index: number) {
    setTodos(todos.filter((_, i) => i !== index));
  }

  // Sorting: spread first, then sort
  function sortTodos() {
    setTodos([...todos].sort());
  }

  // Replacing: map
  function updateTodo(index: number, newText: string) {
    setTodos(todos.map((todo, i) =>
      i === index ? newText : todo
    ));
  }

  // Inserting: slice + spread
  function insertTodo(index: number, text: string) {
    setTodos([
      ...todos.slice(0, index),
      text,
      ...todos.slice(index),
    ]);
  }
}
```

## Mutating vs Non-Mutating Methods

| Mutates (avoid) | Non-mutating (use) |
|-----------------|-------------------|
| `push`, `unshift` | `[...arr, item]`, `[item, ...arr]` |
| `pop`, `shift` | `slice(0, -1)`, `slice(1)` |
| `splice` | `filter`, `slice` + spread |
| `sort`, `reverse` | `[...arr].sort()`, `[...arr].reverse()` |
| `arr[i] = x` | `arr.map((item, i) => i === i ? x : item)` |

## Nested Object Updates

```tsx
// Problem: Nested mutation
function Profile() {
  const [user, setUser] = useState({
    name: 'Alice',
    address: {
      city: 'NYC',
      zip: '10001',
    },
  });

  function updateCity(city: string) {
    // WRONG: Mutating nested object
    user.address.city = city;
    setUser(user);
  }
}
```

## Correct Nested Updates

```tsx
// Solution: Spread at every level
function Profile() {
  const [user, setUser] = useState({
    name: 'Alice',
    address: {
      city: 'NYC',
      zip: '10001',
    },
  });

  function updateCity(city: string) {
    setUser({
      ...user,  // Copy user
      address: {
        ...user.address,  // Copy address
        city,  // Update city
      },
    });
  }
}
```

## Using Immer for Complex Updates

```tsx
// Immer lets you write "mutating" code that produces immutable updates
import { useImmer } from 'use-immer';

function Profile() {
  const [user, updateUser] = useImmer({
    name: 'Alice',
    address: { city: 'NYC', zip: '10001' },
    hobbies: ['reading', 'gaming'],
  });

  function updateCity(city: string) {
    updateUser(draft => {
      // This looks like mutation but Immer handles immutability
      draft.address.city = city;
    });
  }

  function addHobby(hobby: string) {
    updateUser(draft => {
      draft.hobbies.push(hobby);  // Looks like mutation, but safe
    });
  }
}
```

## Key Principle

Treat all values in React state as frozen. When you want to change state, create a new version with the changes rather than modifying the existing one. This lets React detect changes and update the UI correctly.
