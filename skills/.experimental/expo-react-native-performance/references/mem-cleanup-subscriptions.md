---
title: Clean Up Subscriptions in useEffect
impact: MEDIUM
impactDescription: prevents memory leaks from orphaned listeners
tags: mem, cleanup, useEffect, subscriptions
---

## Clean Up Subscriptions in useEffect

Subscriptions to events, WebSockets, or external services must be cleaned up when the component unmounts. Without cleanup, the subscription continues running and accumulates memory.

**Incorrect (subscription never cleaned up):**

```typescript
// hooks/useNotifications.ts
export function useNotifications() {
  const [notifications, setNotifications] = useState<Notification[]>([]);

  useEffect(() => {
    const subscription = Notifications.addNotificationReceivedListener(
      (notification) => {
        setNotifications((prev) => [...prev, notification]);
      }
    );
    // No cleanup - listener keeps running after unmount
  }, []);

  return notifications;
}
// Each mount adds a new listener, none removed
```

**Correct (cleanup on unmount):**

```typescript
// hooks/useNotifications.ts
export function useNotifications() {
  const [notifications, setNotifications] = useState<Notification[]>([]);

  useEffect(() => {
    const subscription = Notifications.addNotificationReceivedListener(
      (notification) => {
        setNotifications((prev) => [...prev, notification]);
      }
    );

    return () => {
      subscription.remove();
    };
  }, []);

  return notifications;
}
// Listener properly removed when component unmounts
```

**Common subscriptions needing cleanup:**
- Event listeners (keyboard, app state, linking)
- WebSocket connections
- Firebase/Supabase real-time subscriptions
- Notification listeners

Reference: [useEffect cleanup](https://react.dev/learn/synchronizing-with-effects#how-to-handle-the-effect-firing-twice-in-development)
