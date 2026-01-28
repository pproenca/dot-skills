---
title: Use Stable Keys Instead of Array Index
impact: CRITICAL
impactDescription: prevents UI glitches and state corruption
tags: list, keys, flatlist, virtualization, reconciliation
---

## Use Stable Keys Instead of Array Index

Using array index as key causes incorrect component reuse when items are added, removed, or reordered.

**Incorrect (index as key):**

```tsx
function TodoList({ todos }) {
  return (
    <FlatList
      data={todos}
      renderItem={({ item, index }) => (
        <TodoItem
          key={index}  // Wrong: key changes when list changes
          todo={item}
        />
      )}
      keyExtractor={(item, index) => index.toString()}  // Also wrong
    />
  )
}

// Problems:
// - Delete item 0 → item 1's state shows on item 0's position
// - Reorder items → animations break, focus lost
// - Add item at start → all items re-render
```

**Correct (stable unique key):**

```tsx
function TodoList({ todos }) {
  return (
    <FlatList
      data={todos}
      renderItem={({ item }) => <TodoItem todo={item} />}
      keyExtractor={item => item.id}  // Stable unique identifier
    />
  )
}

// Each todo has a unique id
const todos = [
  { id: 'todo-1', text: 'Buy groceries', done: false },
  { id: 'todo-2', text: 'Walk dog', done: true },
]
```

**If data lacks IDs, generate stable keys:**

```tsx
// At data fetch time, add IDs
const todosWithIds = apiResponse.map((todo, index) => ({
  ...todo,
  id: todo.id || `generated-${todo.createdAt}-${index}`,
}))

// Or use a combination of unique properties
const keyExtractor = (item) => `${item.name}-${item.createdAt}`

// For truly unique items, use content hash
import * as Crypto from 'expo-crypto'
const generateKey = (item) => Crypto.digestStringAsync(
  Crypto.CryptoDigestAlgorithm.MD5,
  JSON.stringify(item)
)
```

**Why index keys break:**

```tsx
// Initial: [A(0), B(1), C(2)]
// Delete A: [B(0), C(1)]
// B now has key "0" which was A's key
// React thinks B is A and reuses A's component instance

// With stable keys:
// Initial: [A("id-a"), B("id-b"), C("id-c")]
// Delete A: [B("id-b"), C("id-c")]
// Keys match, components correctly identified
```

**When index keys are OK:**
- Static lists that never change
- Lists that are never reordered
- Items have no internal state
- (Even then, prefer stable keys for consistency)

Reference: [React Keys Documentation](https://react.dev/learn/rendering-lists#keeping-list-items-in-order-with-key)
