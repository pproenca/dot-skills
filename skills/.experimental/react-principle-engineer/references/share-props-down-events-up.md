---
title: Props flow down, events flow up
impact: HIGH
impactDescription: React's unidirectional data flow - data passes down through props, change requests bubble up through callbacks
tags: [share, sharing, data-flow, callbacks, events]
---

# Props Flow Down, Events Flow Up

Data flows down the component tree via props. When a child needs to change shared data, it calls a callback prop provided by the parent. This is React's one-way data flow.

## Why This Matters

Unidirectional flow:
- Makes data changes traceable
- Parent always controls the data
- No hidden side effects or mutations
- Easier to debug and reason about

## The Pattern

```tsx
// Parent: owns state, passes data down, receives events up
function TodoApp() {
  const [todos, setTodos] = useState<Todo[]>([]);

  // EVENT HANDLERS: respond to events from children
  function handleAdd(text: string) {
    setTodos([...todos, { id: Date.now(), text, done: false }]);
  }

  function handleToggle(id: number) {
    setTodos(todos.map(t =>
      t.id === id ? { ...t, done: !t.done } : t
    ));
  }

  function handleDelete(id: number) {
    setTodos(todos.filter(t => t.id !== id));
  }

  return (
    <div>
      {/* Data flows DOWN via props */}
      <TodoList
        todos={todos}
        onToggle={handleToggle}  // Callback flows DOWN
        onDelete={handleDelete}  // Callback flows DOWN
      />
      <AddTodo onAdd={handleAdd} />
    </div>
  );
}

// Child: receives data, emits events (doesn't modify data directly)
function TodoList({
  todos,
  onToggle,
  onDelete,
}: {
  todos: Todo[];
  onToggle: (id: number) => void;
  onDelete: (id: number) => void;
}) {
  return (
    <ul>
      {todos.map(todo => (
        <li key={todo.id}>
          <input
            type="checkbox"
            checked={todo.done}
            onChange={() => onToggle(todo.id)}  // Event flows UP
          />
          {todo.text}
          <button onClick={() => onDelete(todo.id)}>  {/* Event UP */}
            Delete
          </button>
        </li>
      ))}
    </ul>
  );
}

function AddTodo({ onAdd }: { onAdd: (text: string) => void }) {
  const [text, setText] = useState('');

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    if (text.trim()) {
      onAdd(text);  // Event flows UP
      setText('');
    }
  }

  return (
    <form onSubmit={handleSubmit}>
      <input value={text} onChange={e => setText(e.target.value)} />
      <button type="submit">Add</button>
    </form>
  );
}
```

## Visualizing the Flow

```
┌─────────────────────────────────────────────────────────┐
│  TodoApp (owns state)                                   │
│  ┌────────────────────────────────────────────────────┐ │
│  │ todos = [...]                                      │ │
│  │                                                    │ │
│  │     ▼ props (data)         ▲ callbacks (events)   │ │
│  └────────────────────────────────────────────────────┘ │
│           │                           │                 │
│           ▼                           │                 │
│  ┌─────────────────┐         ┌────────────────────────┐ │
│  │ TodoList        │         │ Child calls onToggle() │ │
│  │ todos={todos}   │  ◄────  │ to request change      │ │
│  │ onToggle={fn}   │         │                        │ │
│  └─────────────────┘         └────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

## Multiple Levels

```tsx
// Props and callbacks can pass through multiple levels
function App() {
  const [user, setUser] = useState<User | null>(null);

  return (
    <Dashboard
      user={user}
      onLogout={() => setUser(null)}
    />
  );
}

function Dashboard({ user, onLogout }: Props) {
  return (
    <div>
      <Sidebar user={user} onLogout={onLogout} />
      <Content user={user} />
    </div>
  );
}

function Sidebar({ user, onLogout }: Props) {
  return (
    <div>
      <UserMenu user={user} onLogout={onLogout} />
    </div>
  );
}

function UserMenu({ user, onLogout }: Props) {
  return (
    <div>
      <span>{user?.name}</span>
      <button onClick={onLogout}>Logout</button>
    </div>
  );
}

// Data flows: App → Dashboard → Sidebar → UserMenu
// Events flow: UserMenu → Sidebar → Dashboard → App
```

## Why Not Mutate Directly?

```tsx
// Problem: Child modifies data directly
function BadTodoItem({ todo }: { todo: Todo }) {
  function handleToggle() {
    // WRONG: Mutating prop, bypassing React
    todo.done = !todo.done;
    // Parent doesn't know, UI won't update
  }

  return <input checked={todo.done} onChange={handleToggle} />;
}

// Solution: Child requests change via callback
function GoodTodoItem({
  todo,
  onToggle,
}: {
  todo: Todo;
  onToggle: () => void;
}) {
  return <input checked={todo.done} onChange={onToggle} />;
}
```

## Event Naming Conventions

```tsx
// Props that pass callbacks typically use "on" prefix
interface Props {
  // "on" + what happened
  onSelect: (item: Item) => void;
  onDelete: (id: string) => void;
  onChange: (value: string) => void;
  onSubmit: () => void;
  onClose: () => void;
}

// Parent's handlers typically use "handle" prefix
function Parent() {
  function handleSelect(item: Item) { /* ... */ }
  function handleDelete(id: string) { /* ... */ }

  return (
    <Child
      onSelect={handleSelect}
      onDelete={handleDelete}
    />
  );
}
```

## Key Principle

Think of your app as a river. Data flows downstream (parent to child) via props. When something happens downstream, a message flows back upstream (child to parent) via callbacks. The parent decides what to do and updates the data, which flows back down.
