---
title: Use Functional State Updates for Derived Values
impact: MEDIUM-HIGH
impactDescription: prevents stale closures, stable callbacks
tags: state, useState, functional, closures
---

## Use Functional State Updates for Derived Values

When new state depends on previous state, use the functional form of setState. This prevents stale closure bugs and enables stable callbacks.

**Incorrect (stale closure with direct state):**

```typescript
function Counter() {
  const [count, setCount] = useState(0)

  const increment = useCallback(() => {
    setCount(count + 1)  // Captures count at creation time
  }, [count])  // Must include count - callback recreated every render

  return <button onClick={increment}>{count}</button>
}
// increment recreated on every count change
```

**Correct (functional update, stable callback):**

```typescript
function Counter() {
  const [count, setCount] = useState(0)

  const increment = useCallback(() => {
    setCount(c => c + 1)  // Always uses latest count
  }, [])  // Empty deps - never recreated

  return <button onClick={increment}>{count}</button>
}
// increment is stable, safe to pass to memoized children
```

**Multiple updates in sequence:**

```typescript
function handleClick() {
  // Incorrect - all use same count value
  setCount(count + 1)
  setCount(count + 1)
  setCount(count + 1)
  // Result: count + 1 (not count + 3)

  // Correct - each update sees previous result
  setCount(c => c + 1)
  setCount(c => c + 1)
  setCount(c => c + 1)
  // Result: count + 3
}
```
