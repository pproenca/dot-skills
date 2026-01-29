---
title: useEffect is a last resort for side effects
impact: MEDIUM
impactDescription: Most side effects belong in event handlers; useEffect is specifically for synchronizing with external systems
tags: [pure, effects, side-effects, synchronization]
---

# useEffect Is a Last Resort for Side Effects

When you can't find the right event handler for a side effect, useEffect lets you run code after rendering. But this should be your last resort - most side effects naturally belong in event handlers.

## Why This Matters

Misusing useEffect leads to:
- Unnecessary re-renders and effect cycles
- Race conditions and stale data bugs
- Harder to understand component logic
- Performance problems from effects running too often

**Incorrect (anti-pattern):**

```tsx
// Problem: Using effect for event-driven logic
function Form() {
  const [submitted, setSubmitted] = useState(false);
  const [data, setData] = useState('');

  // WRONG - this should be in the submit handler
  useEffect(() => {
    if (submitted) {
      sendFormData(data);
      showNotification('Submitted!');
    }
  }, [submitted, data]);

  function handleSubmit() {
    setSubmitted(true);
  }

  return <form onSubmit={handleSubmit}>...</form>;
}
```

**Correct (recommended):**

```tsx
// Solution: Side effect directly in the event handler
function Form() {
  const [data, setData] = useState('');

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    await sendFormData(data);
    showNotification('Submitted!');
  }

  return <form onSubmit={handleSubmit}>...</form>;
}
```

## When useEffect IS Appropriate

```tsx
// Solution: Synchronizing with an external system
function ChatRoom({ roomId }: { roomId: string }) {
  useEffect(() => {
    // This external connection needs to stay in sync with roomId
    const connection = createConnection(roomId);
    connection.connect();

    return () => {
      connection.disconnect();
    };
  }, [roomId]);

  return <Chat />;
}
```

```tsx
// Solution: Setting up subscriptions
function WindowSize() {
  const [size, setSize] = useState({ width: 0, height: 0 });

  useEffect(() => {
    function handleResize() {
      setSize({
        width: window.innerWidth,
        height: window.innerHeight,
      });
    }

    handleResize();  // Initial value
    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  return <div>{size.width} x {size.height}</div>;
}
```

**Incorrect (anti-pattern):**

```tsx
// Problem: Transforming data in effects
function FilteredList({ items, filter }: Props) {
  const [filteredItems, setFilteredItems] = useState<Item[]>([]);

  // WRONG - unnecessary effect for derived data
  useEffect(() => {
    setFilteredItems(items.filter(item => item.name.includes(filter)));
  }, [items, filter]);

  return <List items={filteredItems} />;
}
```

**Correct (recommended):**

```tsx
// Solution: Calculate during render
function FilteredList({ items, filter }: Props) {
  // Derived value - no effect needed
  const filteredItems = items.filter(item => item.name.includes(filter));

  return <List items={filteredItems} />;
}
```

## Decision Flowchart

Ask yourself:

1. **Is this in response to a user action?** → Use event handler
2. **Is this derived from props/state?** → Calculate during render
3. **Does this sync with an external system?** → Use useEffect
4. **Does this need to run once on mount?** → Consider if it's really external sync
5. **None of the above?** → Probably event handler or render calculation

## Valid useEffect Uses

| Use Case | Why useEffect is Correct |
|----------|-------------------------|
| WebSocket connections | External system sync |
| DOM measurements | Can't know until after paint |
| Third-party library setup | External system |
| Analytics on mount | External system |
| Browser API subscriptions | External system |

## Key Principle

Try to express your logic with rendering and event handlers first. useEffect is your escape hatch for when you truly need to synchronize with something outside React's world.
