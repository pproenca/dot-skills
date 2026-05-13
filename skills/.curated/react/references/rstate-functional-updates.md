---
title: When the next state depends on the previous, pass `setX(prev => …)` — not `setX(x + 1)`
impact: MEDIUM-HIGH
impactDescription: prevents stale-closure bugs in callbacks/effects; enables callbacks with empty deps to remain stable across renders
tags: rstate, functional-setter, stale-closure, stable-callback
---

## When the next state depends on the previous, pass `setX(prev => …)` — not `setX(x + 1)`

**Pattern intent:** state updaters that read the current state should not close over the captured `x` in scope — they should receive `prev` as an argument. This avoids the stale-closure trap and is what lets a `useCallback` with `[]` deps stay stable for the lifetime of the component.

### Shapes to recognize

- `setCount(count + 1)` inside `useCallback(() => ..., [count])` — the dependency forces callback re-creation; switching to `setCount(c => c + 1)` permits `[]` deps.
- Three rapid `setCount(count + 1)` calls in the same handler — only the last one applies, because they all close over the same `count`. The functional form gives `count + 3`.
- A `useEffect` body that reads `count` and calls `setCount(count + delta)` — same stale-closure shape, different host.
- A custom hook returning `increment`/`decrement` whose deps array contains `[count]` — the consumer's child re-renders every increment because the function reference changes.
- A timer/interval setting state with the captured `x` — `setInterval(() => setCount(count + 1), 1000)` produces a counter stuck at 1 unless `count` is a ref or you switch to functional form.

The canonical resolution: when the update depends on the current state, pass an updater function: `setX(prev => f(prev))`. Then deps shrink, callbacks stabilize, and rapid calls compose correctly.

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
