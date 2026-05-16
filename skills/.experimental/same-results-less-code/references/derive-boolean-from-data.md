---
title: Derive Booleans From the Data, Don't Track Them Separately
impact: HIGH
impactDescription: eliminates one boolean of state per "is X?" question (and its sync code)
tags: derive, boolean, state
---

## Derive Booleans From the Data, Don't Track Them Separately

Booleans like `isEmpty`, `hasErrors`, `isComplete`, `isOverdue`, `isPaid` are almost always *questions* about other state, not new facts. Storing them creates a maintenance burden: every place that changes the underlying data must remember to recompute the boolean. The fix is to make them functions (or properties) of the data they describe — the question gets asked at read time, and the answer is automatically correct.

**Incorrect (tracking the boolean as separate state):**

```typescript
class TodoList {
  items: Todo[] = [];
  isEmpty: boolean = true;
  hasOverdue: boolean = false;
  allCompleted: boolean = false;

  add(todo: Todo) {
    this.items.push(todo);
    this.isEmpty = false;
    this.hasOverdue = this.hasOverdue || todo.dueDate < new Date();
    this.allCompleted = this.items.every(t => t.completed);
  }

  complete(id: string) {
    const t = this.items.find(t => t.id === id);
    if (t) t.completed = true;
    this.allCompleted = this.items.every(t => t.completed);
    // Did we update `hasOverdue` too? No — we forgot. Bug.
  }

  remove(id: string) {
    this.items = this.items.filter(t => t.id !== id);
    this.isEmpty = this.items.length === 0;
    // Also forgot to update hasOverdue and allCompleted. Two more bugs.
  }
}
```

**Correct (the booleans ask their question at read time):**

```typescript
class TodoList {
  items: Todo[] = [];

  get isEmpty()     { return this.items.length === 0; }
  get hasOverdue()  { return this.items.some(t => t.dueDate < new Date()); }
  get allCompleted(){ return this.items.every(t => t.completed); }

  add(todo: Todo)     { this.items.push(todo); }
  complete(id: string){ const t = this.items.find(t => t.id === id); if (t) t.completed = true; }
  remove(id: string)  { this.items = this.items.filter(t => t.id !== id); }
}
// Mutations are trivial. Every boolean is always correct.
// The "is the boolean stale?" failure mode no longer exists.
```

**In React, same idea — no need for a boolean state to mirror data:**

```tsx
// Incorrect:
const [items, setItems] = useState<Todo[]>([]);
const [isEmpty, setIsEmpty] = useState(true);
useEffect(() => { setIsEmpty(items.length === 0); }, [items]);

// Correct:
const [items, setItems] = useState<Todo[]>([]);
const isEmpty = items.length === 0;
```

**Symptoms:**

- A boolean whose value is `data.length === 0`, `data.every(...)`, `data.some(...)`, or `data.includes(...)`.
- Every mutation function in a class updates a "status" boolean.
- A bug ticket "X says empty but the list has items."
- A "refresh" / "recompute" function that updates multiple booleans together.

**When NOT to use this pattern:**

- The boolean is *not* a question about other state but an independent user input (e.g. `isPinned` — set by the user, not derived from data). Keep it.
- Computing the boolean is genuinely expensive and reads happen far more often than writes. Cache it explicitly, but write a single function that returns the current answer and call it from getters and writes alike — don't sprinkle invalidation.

Reference: [React docs — Avoid redundant state](https://react.dev/learn/choosing-the-state-structure#avoid-redundant-state)
