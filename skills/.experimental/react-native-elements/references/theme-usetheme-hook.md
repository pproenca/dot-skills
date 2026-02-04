---
title: Access Theme with useTheme Hook
impact: CRITICAL
impactDescription: Enables reactive theme updates and type-safe access to theme values
tags: theme, hooks, typescript, reactivity
---

## Access Theme with useTheme Hook

Using the useTheme hook ensures your components react to theme changes automatically and provides full TypeScript support for theme values. Importing colors directly or hardcoding values breaks reactivity and makes theme switching impossible.

**Incorrect (hardcoding colors or direct imports):**

```tsx
// Bad: Hardcoded color values
const MyComponent = () => {
  return (
    <View style={{ backgroundColor: '#2089dc' }}>
      <Text style={{ color: '#ffffff' }}>Hello</Text>
    </View>
  );
};

// Bad: Importing from a static colors file
import { colors } from './colors';

const MyComponent = () => {
  return (
    <View style={{ backgroundColor: colors.primary }}>
      <Text style={{ color: colors.white }}>Hello</Text>
    </View>
  );
};
```

**Correct (using useTheme hook for dynamic access):**

```tsx
import { useTheme } from '@rneui/themed';

const MyComponent = () => {
  // Access theme reactively with full TypeScript support
  const { theme } = useTheme();

  return (
    <View style={{ backgroundColor: theme.colors.primary }}>
      <Text style={{ color: theme.colors.white }}>Hello</Text>
    </View>
  );
};
```

Reference: [React Native Elements Customization](https://reactnativeelements.com/docs/customization)
