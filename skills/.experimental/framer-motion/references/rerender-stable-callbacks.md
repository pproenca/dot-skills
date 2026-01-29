---
title: Keep Animation Callbacks Stable with useCallback
impact: CRITICAL
impactDescription: prevents child component re-renders on parent state changes
tags: rerender, useCallback, callbacks, memoization, children
---

## Keep Animation Callbacks Stable with useCallback

Inline callback functions create new function references on every render, breaking memoization of child components and causing unnecessary re-renders. Animation callbacks like onAnimationComplete, onDragEnd, and onHoverStart should be memoized with useCallback to maintain referential equality.

**Incorrect (inline callback breaks memoization):**

```tsx
function AnimatedList({ items }) {
  const [selected, setSelected] = useState(null);

  return (
    <motion.ul>
      {items.map((item) => (
        <MemoizedListItem
          key={item.id}
          item={item}
          onAnimationComplete={() => console.log(`${item.id} animated`)}  // New function every render
        />
      ))}
    </motion.ul>
  );
}
```

**Correct (memoized callback preserves child memoization):**

```tsx
function AnimatedList({ items }) {
  const [selected, setSelected] = useState(null);

  const handleAnimationComplete = useCallback((id: string) => {
    console.log(`${id} animated`);
  }, []);

  return (
    <motion.ul>
      {items.map((item) => (
        <MemoizedListItem
          key={item.id}
          item={item}
          onAnimationComplete={() => handleAnimationComplete(item.id)}  // Stable reference
        />
      ))}
    </motion.ul>
  );
}
```

Reference: [React - useCallback](https://react.dev/reference/react/useCallback)
