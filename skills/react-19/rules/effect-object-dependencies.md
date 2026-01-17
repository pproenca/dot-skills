---
title: Avoid Object and Array Dependencies in Effects
impact: MEDIUM
impactDescription: prevents infinite loops, unnecessary re-runs
tags: effect, dependencies, objects, arrays
---

## Avoid Object and Array Dependencies in Effects

Objects and arrays created during render have new references each time. Move them outside the component, inside the effect, or memoize them.

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
