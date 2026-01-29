---
title: Derive values instead of storing redundant state
impact: HIGH
impactDescription: State that can be calculated from other state creates sync bugs and unnecessary complexity
tags: [state, structure, derived, calculation, redundancy]
---

# Derive Values Instead of Storing Redundant State

If you can calculate a value from existing props or state during rendering, don't store it in state. Calculate it during render instead.

## Why This Matters

Redundant state:
- Can become out of sync with the source data
- Requires extra code to keep synchronized
- Makes state updates more complex
- Wastes memory storing duplicate information

**Incorrect (anti-pattern):**

```tsx
// Problem: Storing fullName when it can be calculated
function Form() {
  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');
  const [fullName, setFullName] = useState('');  // REDUNDANT

  function handleFirstNameChange(e: ChangeEvent<HTMLInputElement>) {
    setFirstName(e.target.value);
    setFullName(e.target.value + ' ' + lastName);  // Must remember!
  }

  function handleLastNameChange(e: ChangeEvent<HTMLInputElement>) {
    setLastName(e.target.value);
    setFullName(firstName + ' ' + e.target.value);  // Must remember!
  }

  return (
    <>
      <input value={firstName} onChange={handleFirstNameChange} />
      <input value={lastName} onChange={handleLastNameChange} />
      <p>Full name: {fullName}</p>
    </>
  );
}
```

**Correct (recommended):**

```tsx
// Solution: Calculate fullName during render
function Form() {
  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');

  // Derived value - always correct, no sync needed
  const fullName = firstName + ' ' + lastName;

  return (
    <>
      <input
        value={firstName}
        onChange={e => setFirstName(e.target.value)}
      />
      <input
        value={lastName}
        onChange={e => setLastName(e.target.value)}
      />
      <p>Full name: {fullName}</p>
    </>
  );
}
```

**Incorrect (anti-pattern):**

```tsx
// Problem: Storing derived counts
function TodoList() {
  const [todos, setTodos] = useState<Todo[]>([]);
  const [totalCount, setTotalCount] = useState(0);      // REDUNDANT
  const [completedCount, setCompletedCount] = useState(0);  // REDUNDANT

  function addTodo(text: string) {
    setTodos([...todos, { id: Date.now(), text, done: false }]);
    setTotalCount(totalCount + 1);  // Must remember!
  }

  function toggleTodo(id: number) {
    const newTodos = todos.map(t =>
      t.id === id ? { ...t, done: !t.done } : t
    );
    setTodos(newTodos);
    // Now must recalculate completedCount... easy to get wrong
    const newCompleted = newTodos.filter(t => t.done).length;
    setCompletedCount(newCompleted);
  }
}
```

**Correct (recommended):**

```tsx
// Solution: Calculate counts from todos array
function TodoList() {
  const [todos, setTodos] = useState<Todo[]>([]);

  // Derived values - always correct
  const totalCount = todos.length;
  const completedCount = todos.filter(t => t.done).length;
  const remainingCount = totalCount - completedCount;

  function addTodo(text: string) {
    setTodos([...todos, { id: Date.now(), text, done: false }]);
    // Counts update automatically!
  }

  function toggleTodo(id: number) {
    setTodos(todos.map(t =>
      t.id === id ? { ...t, done: !t.done } : t
    ));
    // Counts update automatically!
  }

  return (
    <div>
      <p>{completedCount} of {totalCount} complete</p>
      {/* ... */}
    </div>
  );
}
```

## When Calculation is Expensive

```tsx
// For expensive calculations, use useMemo
function FilteredList({ items, filter }: Props) {
  // Only recalculates when items or filter changes
  const filteredItems = useMemo(
    () => items.filter(item => matchesFilter(item, filter)),
    [items, filter]
  );

  // Very expensive calculation
  const stats = useMemo(
    () => calculateComplexStats(filteredItems),
    [filteredItems]
  );

  return (
    <div>
      <Stats data={stats} />
      <List items={filteredItems} />
    </div>
  );
}
```

## Signs of Redundant State

```tsx
// RED FLAGS:

// State that's a transformation of other state
const [items, setItems] = useState<Item[]>([]);
const [sortedItems, setSortedItems] = useState<Item[]>([]);  // ❌

// State that's a subset of other state
const [allUsers, setAllUsers] = useState<User[]>([]);
const [activeUsers, setActiveUsers] = useState<User[]>([]);  // ❌

// State that's a count of other state
const [messages, setMessages] = useState<Message[]>([]);
const [unreadCount, setUnreadCount] = useState(0);  // ❌

// State that combines other state
const [firstName, setFirstName] = useState('');
const [lastName, setLastName] = useState('');
const [fullName, setFullName] = useState('');  // ❌
```

## Correct Patterns

```tsx
// GOOD PATTERNS:

const [items, setItems] = useState<Item[]>([]);
const sortedItems = [...items].sort(compareItems);  // ✅ Derived

const [allUsers, setAllUsers] = useState<User[]>([]);
const activeUsers = allUsers.filter(u => u.isActive);  // ✅ Derived

const [messages, setMessages] = useState<Message[]>([]);
const unreadCount = messages.filter(m => !m.isRead).length;  // ✅ Derived

const [firstName, setFirstName] = useState('');
const [lastName, setLastName] = useState('');
const fullName = `${firstName} ${lastName}`;  // ✅ Derived
```

## Key Principle

State is the source of truth. Everything derivable from that source of truth should be calculated, not stored. This is like database normalization - don't store what you can compute.
