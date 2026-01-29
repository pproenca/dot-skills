---
title: Use updater functions for state based on previous state
impact: HIGH
impactDescription: Updater functions ensure you're working with the latest pending state value, not a stale snapshot
tags: [state, updater, previous, batching, async]
---

# Use Updater Functions for State Based on Previous State

When calculating the next state from the previous state, pass a function to `setState`. This function receives the pending state and returns the next state.

## Why This Matters

Updater functions:
- Receive the latest pending state value
- Work correctly with batched updates
- Handle rapid updates properly
- Are essential for async operations

**Incorrect (anti-pattern):**

```tsx
// Problem: Using the snapshot value for increments
function Counter() {
  const [count, setCount] = useState(0);

  function handleClick() {
    // All three read count from the SAME snapshot
    setCount(count + 1);  // 0 + 1 = 1
    setCount(count + 1);  // 0 + 1 = 1 (not 2!)
    setCount(count + 1);  // 0 + 1 = 1 (not 3!)
  }

  return <button onClick={handleClick}>{count}</button>;
}
// After click: 1, not 3
```

**Correct (recommended):**

```tsx
// Solution: Use updater function for sequential updates
function Counter() {
  const [count, setCount] = useState(0);

  function handleClick() {
    // Each updater receives the result of the previous
    setCount(c => c + 1);  // 0 + 1 = 1
    setCount(c => c + 1);  // 1 + 1 = 2
    setCount(c => c + 1);  // 2 + 1 = 3
  }

  return <button onClick={handleClick}>{count}</button>;
}
// After click: 3
```

## Naming Convention

```tsx
// Use a short name related to the state variable
const [count, setCount] = useState(0);
setCount(c => c + 1);  // c for count

const [age, setAge] = useState(42);
setAge(a => a + 1);  // a for age

const [todos, setTodos] = useState<Todo[]>([]);
setTodos(t => [...t, newTodo]);  // t for todos

// Or use "prev" prefix for clarity
setCount(prevCount => prevCount + 1);
setTodos(prevTodos => [...prevTodos, newTodo]);
```

## When to Use Each Form

```tsx
function Demo() {
  const [name, setName] = useState('');
  const [count, setCount] = useState(0);

  // DIRECT VALUE: When new state doesn't depend on old state
  function handleNameChange(newName: string) {
    setName(newName);  // Just setting to a new value
  }

  // UPDATER: When calculating from previous state
  function handleIncrement() {
    setCount(c => c + 1);  // Depends on previous count
  }

  // UPDATER: When adding to an array
  function handleAddItem(item: Item) {
    setItems(prev => [...prev, item]);  // Depends on previous items
  }

  // DIRECT: When replacing entirely
  function handleClearItems() {
    setItems([]);  // Not derived from previous
  }
}
```

## With Objects

```tsx
function Profile() {
  const [user, setUser] = useState({ name: 'Alice', age: 25 });

  // DIRECT: Replacing a property with a known value
  function handleNameChange(newName: string) {
    setUser({ ...user, name: newName });  // OK, name is from event
  }

  // UPDATER: When new value depends on old value
  function handleBirthday() {
    setUser(prev => ({
      ...prev,
      age: prev.age + 1,  // Depends on previous age
    }));
  }
}
```

## Common Pattern: Toggle

```tsx
function Toggle() {
  const [isOn, setIsOn] = useState(false);

  // CORRECT: Toggle depends on previous state
  function handleToggle() {
    setIsOn(prev => !prev);
  }

  // WRONG: Could fail with rapid clicks
  function handleToggleBad() {
    setIsOn(!isOn);  // Uses snapshot, might be stale
  }

  return <button onClick={handleToggle}>{isOn ? 'ON' : 'OFF'}</button>;
}
```

## With Arrays

```tsx
function TodoList() {
  const [todos, setTodos] = useState<Todo[]>([]);

  // ADD: depends on previous array
  function addTodo(text: string) {
    setTodos(prev => [
      ...prev,
      { id: Date.now(), text, done: false }
    ]);
  }

  // TOGGLE: depends on previous state
  function toggleTodo(id: number) {
    setTodos(prev =>
      prev.map(todo =>
        todo.id === id ? { ...todo, done: !todo.done } : todo
      )
    );
  }

  // REMOVE: depends on previous array
  function removeTodo(id: number) {
    setTodos(prev => prev.filter(todo => todo.id !== id));
  }

  // CLEAR: doesn't depend on previous
  function clearTodos() {
    setTodos([]);  // Direct value is fine here
  }
}
```

## Async Operations

```tsx
function Counter() {
  const [count, setCount] = useState(0);

  async function handleClick() {
    // Updater ensures we use the LATEST state after await
    await someAsyncOperation();

    // WRONG: count might be stale after await
    setCount(count + 1);

    // CORRECT: updater gets current state
    setCount(c => c + 1);
  }
}
```

## Key Principle

Ask: "Does my next state depend on my previous state?" If yes, use an updater function. The updater receives a "queue" of pending state values, ensuring your calculation always uses the latest value.
