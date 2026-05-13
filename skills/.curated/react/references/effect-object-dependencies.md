---
title: Effect deps are reference-compared — pass primitives, not in-render-constructed objects or arrays
impact: MEDIUM
impactDescription: prevents infinite re-run loops and unnecessary subscription churn from new-object identities on every render
tags: effect, dep-stability, primitive-deps, reference-identity
---

## Effect deps are reference-compared — pass primitives, not in-render-constructed objects or arrays

**Pattern intent:** React compares dependencies with `Object.is`. A `{...}` literal or `[...]` created during render is a new identity every render, so any effect that "depends on" it re-runs every render — usually causing an infinite loop if the effect also calls `setState`.

### Shapes to recognize

- `const options = { roomId, url }` declared in the component body, then `useEffect(..., [options])` — `options` is new every render.
- A custom hook called with a fresh object: `useChat({ roomId, url })` — the *consumer* allocates a new object each render; the hook receives a non-stable identity.
- An effect with a function dependency where the function is defined inline in the component body — same problem, different shape.
- Workaround: `JSON.stringify(options)` as a dep — works but allocates and re-stringifies; the cleaner fix is to use primitive fields.
- Workaround: a `useMemo` wrapping the options object to "stabilize" it — *can* work, but only if the memo's own deps are themselves stable. Often the problem just moves.
- Eslint-disabled `exhaustive-deps` to hide the warning — silences the symptom, not the cause.

The canonical resolution: list the *primitive fields* the effect actually consumes in the dep array; build the object inside the effect body. If the consumer must pass an object, `useMemo` it keyed on the primitive parts.

**Incorrect (object dependency causes infinite loop):**

```typescript
function ChatRoom({ roomId }) {
  const options = { roomId, serverUrl: 'https://chat.example.com' }

  useEffect(() => {
    const connection = createConnection(options)
    connection.connect()
    return () => connection.disconnect()
  }, [options])  // New object every render = infinite loop!
}
```

**Correct (extract primitive dependencies):**

```typescript
function ChatRoom({ roomId }) {
  useEffect(() => {
    const options = { roomId, serverUrl: 'https://chat.example.com' }
    const connection = createConnection(options)
    connection.connect()
    return () => connection.disconnect()
  }, [roomId])  // Primitive dependency, stable
}
```

**Alternative (memoize if object must be prop):**

```typescript
function ChatRoom({ roomId }) {
  const options = useMemo(() => ({
    roomId,
    serverUrl: 'https://chat.example.com'
  }), [roomId])

  useEffect(() => {
    const connection = createConnection(options)
    connection.connect()
    return () => connection.disconnect()
  }, [options])  // Stable reference when roomId is same
}
```

**Best practice:** Always use primitive values in dependency arrays when possible. If you need an object, create it inside the effect.
