---
title: Avoid Inline Objects and Arrays in Props
impact: MEDIUM
impactDescription: prevents unnecessary re-renders from new references
tags: mem, inline, objects, memoization
---

## Avoid Inline Objects and Arrays in Props

Inline objects and arrays create new references on every render. When passed as props to memoized components, this defeats memoization and causes unnecessary re-renders.

**Incorrect (new object reference every render):**

```typescript
// screens/SettingsScreen.tsx
export function SettingsScreen() {
  const [darkMode, setDarkMode] = useState(false);

  return (
    <View>
      <Toggle value={darkMode} onChange={setDarkMode} />
      <UserAvatar
        style={{ width: 50, height: 50 }}  // New object every render
        source={{ uri: user.avatarUrl }}   // New object every render
      />
    </View>
  );
}
// UserAvatar re-renders on every darkMode toggle
```

**Correct (stable object references):**

```typescript
// screens/SettingsScreen.tsx
const avatarStyle = { width: 50, height: 50 };

export function SettingsScreen() {
  const [darkMode, setDarkMode] = useState(false);

  const avatarSource = useMemo(
    () => ({ uri: user.avatarUrl }),
    [user.avatarUrl]
  );

  return (
    <View>
      <Toggle value={darkMode} onChange={setDarkMode} />
      <UserAvatar style={avatarStyle} source={avatarSource} />
    </View>
  );
}
// UserAvatar only re-renders when avatarUrl changes
```

**Patterns for stable references:**
- Static styles: Define outside component
- Dynamic values: Use `useMemo`
- Empty arrays: Use module-level `const EMPTY_ARRAY = []`

Reference: [Avoiding Recreating Objects](https://react.dev/reference/react/useMemo#skipping-re-rendering-of-components)
