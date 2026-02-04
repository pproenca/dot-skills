---
title: Use Functional setState Updates
impact: HIGH
impactDescription: eliminates state dependency from callbacks
tags: rerender, useState, functional-update, callbacks
---

## Use Functional setState Updates

When updating state based on the current value, use the functional form of setState. This eliminates the need to include state in callback dependencies, allowing truly stable callbacks.

**Incorrect (state in dependency array recreates callback):**

```typescript
// screens/Counter.tsx
export function Counter() {
  const [count, setCount] = useState(0);

  // Recreated every time count changes
  const increment = useCallback(() => {
    setCount(count + 1);
  }, [count]);

  return (
    <MemoizedButton onPress={increment} />  // Re-renders on every count change
  );
}
```

**Correct (functional update, empty deps):**

```typescript
// screens/Counter.tsx
export function Counter() {
  const [count, setCount] = useState(0);

  // Never recreated - truly stable callback
  const increment = useCallback(() => {
    setCount((c) => c + 1);
  }, []);

  return (
    <MemoizedButton onPress={increment} />  // Never re-renders from callback change
  );
}
```

**Pattern applies to:**
- Incrementing/decrementing numbers
- Toggling booleans: `setValue(v => !v)`
- Adding to arrays: `setItems(items => [...items, newItem])`
- Updating object properties: `setUser(u => ({ ...u, name }))`

Reference: [useState functional updates](https://react.dev/reference/react/useState#updating-state-based-on-the-previous-state)
