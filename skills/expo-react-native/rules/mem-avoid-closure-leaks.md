---
title: Avoid Closure-Based Memory Leaks in Callbacks
impact: LOW-MEDIUM
impactDescription: prevents retained references to unmounted component state
tags: mem, closures, callbacks, refs
---

## Avoid Closure-Based Memory Leaks in Callbacks

Closures in callbacks can retain references to component state and props, preventing garbage collection even after unmount. Use refs for values needed in long-lived callbacks.

**Incorrect (closure retains entire component scope):**

```typescript
function NotificationHandler({ userId, onNotification }) {
  const [notifications, setNotifications] = useState([])

  useEffect(() => {
    const handleNotification = (notification) => {
      // Closure captures entire component scope
      console.log(`User ${userId} received:`, notification)
      setNotifications(prev => [...prev, notification])
      onNotification(notification)
    }

    const subscription = NotificationService.subscribe(handleNotification)

    return () => subscription.unsubscribe()
  }, [userId, onNotification])  // Recreated on every userId change

  return <NotificationList notifications={notifications} />
}
```

**Correct (refs for stable callback values):**

```typescript
function NotificationHandler({ userId, onNotification }) {
  const [notifications, setNotifications] = useState([])
  const userIdRef = useRef(userId)
  const onNotificationRef = useRef(onNotification)

  // Keep refs updated
  useEffect(() => {
    userIdRef.current = userId
  }, [userId])

  useEffect(() => {
    onNotificationRef.current = onNotification
  }, [onNotification])

  useEffect(() => {
    const handleNotification = (notification) => {
      // Refs don't cause recreation, minimal closure
      console.log(`User ${userIdRef.current} received:`, notification)
      setNotifications(prev => [...prev, notification])
      onNotificationRef.current(notification)
    }

    const subscription = NotificationService.subscribe(handleNotification)

    return () => subscription.unsubscribe()
  }, [])  // Stable effect, never recreated

  return <NotificationList notifications={notifications} />
}
```

**useLatest hook pattern:**

```typescript
function useLatest(value) {
  const ref = useRef(value)
  useEffect(() => {
    ref.current = value
  }, [value])
  return ref
}

function NotificationHandler({ userId, onNotification }) {
  const userIdRef = useLatest(userId)
  const onNotificationRef = useLatest(onNotification)

  useEffect(() => {
    const handleNotification = (notification) => {
      console.log(`User ${userIdRef.current} received:`, notification)
      onNotificationRef.current(notification)
    }

    const subscription = NotificationService.subscribe(handleNotification)
    return () => subscription.unsubscribe()
  }, [])

  // ...
}
```

**When to use this pattern:**
- Event listeners that outlive renders
- WebSocket message handlers
- Push notification callbacks
- Background task callbacks
