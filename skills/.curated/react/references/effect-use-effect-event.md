---
title: Read latest props/state inside an effect's callback without re-subscribing when those values change
impact: MEDIUM
impactDescription: stops the "include this dep just to read latest value" → "but now my effect re-runs whenever it changes" cycle; the value reads always-fresh without re-triggering the effect
tags: effect, non-reactive-read, effect-event, latest-value
---

## Read latest props/state inside an effect's callback without re-subscribing when those values change

**Pattern intent:** sometimes an effect's body (or an inner callback the effect attaches as a listener) needs the *latest* value of some prop/state, but the effect itself should *not* re-run when that prop/state changes. `useEffectEvent` (React 19.2+) gives you a function whose closure always sees the latest values but doesn't count as a dep.

### Shapes to recognize

- Effect deps include a value that's read in a logging/analytics path but the effect's setup/teardown doesn't depend on it — "I need the latest theme inside the message handler, but I don't want to reconnect when theme changes."
- Workaround: a `useRef(value)` plus a `useEffect(() => { ref.current = value })` to keep a ref in sync with the latest value — exactly what `useEffectEvent` does, but hand-rolled.
- Workaround: an `eslint-disable-next-line react-hooks/exhaustive-deps` comment over a `useEffect` whose deps array is intentionally incomplete — concedes the problem instead of solving it.
- A child callback prop captured in an effect's dep array, where the callback's identity changes but its behavior shouldn't trigger re-subscription.
- A `useEffect` that subscribes to an external system and reads a piece of state to format the notification — should pull the format logic into a `useEffectEvent`.

The canonical resolution: extract the latest-value-reading path into a `useEffectEvent(callback)`; remove the now-non-reactive deps from the effect; effect re-subscribes only when *truly* reactive deps change.

> **Version note:** `useEffectEvent` is stable in React 19.2+. For earlier React 19, use the `useRef` + sync-effect workaround; suppressing `exhaustive-deps` is not equivalent.

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

**Note:** `useEffectEvent` is stable starting in React 19.2 (October 2025). Requires `react@19.2.0` or later — if targeting earlier React 19 versions, use a ref-based workaround instead. It replaces the pattern of suppressing exhaustive-deps warnings.
