---
title: Stabilize Callbacks with useCallback
impact: HIGH
impactDescription: prevents child re-renders from new function refs
tags: rerender, useCallback, callbacks, stability
---

## Stabilize Callbacks with useCallback

Functions defined inside components get new references on every render. When passed as props to memoized children, this breaks memoization. Use `useCallback` to maintain stable function references.

**Incorrect (new callback reference breaks child memo):**

```typescript
// screens/UserSettings.tsx
export function UserSettings({ userId }: Props) {
  const [notifications, setNotifications] = useState(true);

  // New function created every render
  const handleSave = async () => {
    await saveSettings(userId, { notifications });
  };

  return (
    <>
      <Toggle value={notifications} onValueChange={setNotifications} />
      <SaveButton onPress={handleSave} />  {/* Re-renders on toggle */}
    </>
  );
}

const SaveButton = memo(({ onPress }: { onPress: () => void }) => (
  <Pressable onPress={onPress}><Text>Save</Text></Pressable>
));
```

**Correct (stable callback preserves child memo):**

```typescript
// screens/UserSettings.tsx
export function UserSettings({ userId }: Props) {
  const [notifications, setNotifications] = useState(true);

  const handleSave = useCallback(async () => {
    await saveSettings(userId, { notifications });
  }, [userId, notifications]);

  return (
    <>
      <Toggle value={notifications} onValueChange={setNotifications} />
      <SaveButton onPress={handleSave} />  {/* Only re-renders when deps change */}
    </>
  );
}

const SaveButton = memo(({ onPress }: { onPress: () => void }) => (
  <Pressable onPress={onPress}><Text>Save</Text></Pressable>
));
```

**Note:** `useCallback` only helps when the callback is passed to a memoized component. Without `memo` on the child, it re-renders anyway.

Reference: [useCallback](https://react.dev/reference/react/useCallback)
