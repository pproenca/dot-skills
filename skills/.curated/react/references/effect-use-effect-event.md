---
title: Use useEffectEvent for Non-Reactive Logic
impact: MEDIUM
impactDescription: separates reactive from non-reactive code
tags: effect, useEffectEvent, non-reactive, events
---

## Use useEffectEvent for Non-Reactive Logic

`useEffectEvent` creates a function that always sees the latest values but doesn't trigger effect re-runs. Use it for "event-like" behavior inside effects.

**Incorrect (including non-reactive values in deps):**

```typescript
function ChatRoom({ roomId, theme }) {
  useEffect(() => {
    const connection = createConnection(roomId)
    connection.on('message', (msg) => {
      // theme is needed but shouldn't reconnect when it changes
      showNotification(msg, theme)
    })
    connection.connect()
    return () => connection.disconnect()
  }, [roomId, theme])  // Reconnects when theme changes!
}
```

**Correct (useEffectEvent for non-reactive logic):**

```typescript
import { useEffect, useEffectEvent } from 'react'

function ChatRoom({ roomId, theme }) {
  // Non-reactive: doesn't cause effect to re-run
  const onMessage = useEffectEvent((msg: Message) => {
    showNotification(msg, theme)  // Always reads latest theme
  })

  useEffect(() => {
    const connection = createConnection(roomId)
    connection.on('message', onMessage)
    connection.connect()
    return () => connection.disconnect()
  }, [roomId])  // Only reconnects when roomId changes
}
```

**When to use useEffectEvent:**
- Reading latest props/state in effect callbacks
- Logging/analytics that shouldn't re-trigger effects
- Side effects that depend on current values but aren't "about" those values

**Note:** `useEffectEvent` is stable in React 19.2. It replaces the pattern of suppressing exhaustive-deps warnings.
