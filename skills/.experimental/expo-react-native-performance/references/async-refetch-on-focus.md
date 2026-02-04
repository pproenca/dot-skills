---
title: Refetch Data on Screen Focus
impact: MEDIUM
impactDescription: prevents stale data after hours in background
tags: async, focus, refetch, navigation
---

## Refetch Data on Screen Focus

Mobile apps stay in background for extended periods. Refetch important data when the screen becomes focused to ensure users see current information.

**Incorrect (data stale after background):**

```typescript
// screens/NotificationsScreen.tsx
export function NotificationsScreen() {
  const [notifications, setNotifications] = useState<Notification[]>([]);

  useEffect(() => {
    fetchNotifications().then(setNotifications);
  }, []);

  // User backgrounds app, returns hours later, sees stale notifications
  return <NotificationList notifications={notifications} />;
}
```

**Correct (refetch on screen focus):**

```typescript
// screens/NotificationsScreen.tsx
import { useFocusEffect } from '@react-navigation/native';

export function NotificationsScreen() {
  const [notifications, setNotifications] = useState<Notification[]>([]);

  useFocusEffect(
    useCallback(() => {
      fetchNotifications().then(setNotifications);
    }, [])
  );

  // Fresh data loaded every time screen becomes visible
  return <NotificationList notifications={notifications} />;
}
```

**With TanStack Query (automatic):**

```typescript
import { useQuery } from '@tanstack/react-query';
import { useFocusEffect } from '@react-navigation/native';

export function NotificationsScreen() {
  const { data: notifications, refetch } = useQuery({
    queryKey: ['notifications'],
    queryFn: fetchNotifications,
  });

  useFocusEffect(useCallback(() => { refetch(); }, [refetch]));

  return <NotificationList notifications={notifications ?? []} />;
}
```

**Note:** Balance freshness with performance. Not every screen needs refetch on focus.

Reference: [useFocusEffect](https://reactnavigation.org/docs/use-focus-effect/)
