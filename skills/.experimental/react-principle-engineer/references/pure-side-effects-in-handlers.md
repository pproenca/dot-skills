---
title: Side effects belong in event handlers, not render
impact: HIGH
impactDescription: Event handlers run in response to user actions and are the natural place for side effects like API calls and mutations
tags: [pure, events, side-effects, handlers]
---

# Side Effects Belong in Event Handlers, Not Render

Event handlers don't run during rendering, so they don't need to be pure. They are the primary place for side effects: updating state, calling APIs, changing the DOM, navigating, etc.

## Why This Matters

Event handlers:
- Run in response to specific user actions
- Execute at a predictable time (when the event fires)
- Can safely mutate state and perform side effects
- Keep render pure and predictable

**Incorrect (anti-pattern):**

```tsx
// Problem: DOM manipulation during render
function ClockWithDOMAccess({ time }: { time: Date }) {
  const hours = time.getHours();

  // WRONG - touching the DOM during render
  if (hours >= 0 && hours <= 6) {
    document.getElementById('time')!.className = 'night';
  } else {
    document.getElementById('time')!.className = 'day';
  }

  return <h1 id="time">{time.toLocaleTimeString()}</h1>;
}
```

**Correct (recommended):**

```tsx
// Solution: Calculate class during render, no side effects
function Clock({ time }: { time: Date }) {
  const hours = time.getHours();
  const className = hours >= 0 && hours <= 6 ? 'night' : 'day';

  return <h1 className={className}>{time.toLocaleTimeString()}</h1>;
}
```

**Incorrect (anti-pattern):**

```tsx
// Problem: API call during render
function UserProfile({ userId }: { userId: string }) {
  // WRONG - side effect during render
  fetch(`/api/users/${userId}`)
    .then(res => res.json())
    .then(data => {
      // This won't even work correctly
    });

  return <div>Loading...</div>;
}
```

**Correct (recommended):**

```tsx
// Solution: API call in event handler or effect
function UserProfile({ userId }: { userId: string }) {
  const [user, setUser] = useState<User | null>(null);

  // Effect for data that needs to sync with props/state
  useEffect(() => {
    let cancelled = false;

    fetch(`/api/users/${userId}`)
      .then(res => res.json())
      .then(data => {
        if (!cancelled) setUser(data);
      });

    return () => { cancelled = true; };
  }, [userId]);

  if (!user) return <div>Loading...</div>;
  return <div>{user.name}</div>;
}
```

## Side Effects in Event Handlers

```tsx
function TodoApp() {
  const [todos, setTodos] = useState<Todo[]>([]);

  // Event handlers are the perfect place for side effects
  async function handleAddTodo(text: string) {
    // API call - side effect, fine in handler
    const newTodo = await api.createTodo(text);

    // Analytics - side effect, fine in handler
    analytics.track('todo_created', { text });

    // State update
    setTodos(prev => [...prev, newTodo]);
  }

  async function handleDeleteTodo(id: string) {
    // Optimistic update
    setTodos(prev => prev.filter(t => t.id !== id));

    // API call with error handling
    try {
      await api.deleteTodo(id);
    } catch (error) {
      // Revert on failure
      setTodos(prev => [...prev, todos.find(t => t.id === id)!]);
    }
  }

  return (
    <div>
      <TodoForm onSubmit={handleAddTodo} />
      <TodoList todos={todos} onDelete={handleDeleteTodo} />
    </div>
  );
}
```

## When to Use useEffect vs Event Handlers

```tsx
// Use event handlers for:
// - User-initiated actions (clicks, form submissions)
// - Responses to specific interactions

function Form() {
  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    await api.submitForm(data);  // Event handler - correct
  }

  return <form onSubmit={handleSubmit}>...</form>;
}

// Use effects for:
// - Synchronizing with external systems
// - Things that need to happen when props/state change

function ChatRoom({ roomId }: { roomId: string }) {
  useEffect(() => {
    // Sync with external system - effect is correct
    const connection = createConnection(roomId);
    connection.connect();
    return () => connection.disconnect();
  }, [roomId]);

  return <Chat />;
}
```

## Key Principle

Rendering describes what the UI should look like. Event handlers describe what should happen when something is done. Keep them separate: render pure, handlers effectful.
