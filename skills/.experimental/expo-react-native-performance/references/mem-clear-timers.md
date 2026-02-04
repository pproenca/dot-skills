---
title: Clear Timers on Unmount
impact: MEDIUM
impactDescription: prevents memory leaks and setState errors
tags: mem, timers, cleanup, setTimeout
---

## Clear Timers on Unmount

Timers (setTimeout, setInterval) continue running after unmount. If the callback updates state, it causes "Can't perform state update on unmounted component" errors and memory leaks.

**Incorrect (timer not cleared):**

```typescript
// components/Toast.tsx
export function Toast({ message, duration = 3000 }: Props) {
  const [visible, setVisible] = useState(true);

  useEffect(() => {
    setTimeout(() => {
      setVisible(false);  // Runs even if component unmounted
    }, duration);
  }, [duration]);

  if (!visible) return null;
  return <View style={styles.toast}><Text>{message}</Text></View>;
}
// If user navigates away quickly, setState called on unmounted component
```

**Correct (timer cleared on unmount):**

```typescript
// components/Toast.tsx
export function Toast({ message, duration = 3000 }: Props) {
  const [visible, setVisible] = useState(true);

  useEffect(() => {
    const timeoutId = setTimeout(() => {
      setVisible(false);
    }, duration);

    return () => {
      clearTimeout(timeoutId);
    };
  }, [duration]);

  if (!visible) return null;
  return <View style={styles.toast}><Text>{message}</Text></View>;
}
// Timer cancelled if component unmounts early
```

**For setInterval:**

```typescript
useEffect(() => {
  const intervalId = setInterval(pollForUpdates, 5000);
  return () => clearInterval(intervalId);
}, []);
```

Reference: [React Native Memory Leak Prevention](https://instamobile.io/blog/react-native-memory-leak-fixes/)
