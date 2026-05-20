---
title: Drive colors from the active color scheme
impact: HIGH
impactDescription: enables automatic light and dark adaptation
tags: layout, dark-mode, color-scheme, theming
---

## Drive colors from the active color scheme

iOS users switch between light and dark — often on a schedule — and an app that ignores the setting glares white in a dark room or washes out in daylight. Hardcoding a single palette forces one appearance on everyone. Read the live scheme with `useColorScheme()` and resolve colors from a theme so every surface flips automatically, including when the user toggles mid-session.

**Incorrect (single hardcoded palette):**

```tsx
import { View, Text } from 'react-native';

// Always light: blinding in dark mode, and never tracks the user's setting
function TrailCard({ trail }: { trail: Trail }) {
  return (
    <View style={{ backgroundColor: '#ffffff' }}>
      <Text style={{ color: '#000000' }}>{trail.name}</Text>
    </View>
  );
}
```

**Correct (theme resolved from the active scheme):**

```tsx
import { View, Text, useColorScheme } from 'react-native';

// Surfaces and text flip with the system setting, including live toggles
function TrailCard({ trail }: { trail: Trail }) {
  const theme = useColorScheme() === 'dark' ? darkTheme : lightTheme;
  return (
    <View style={{ backgroundColor: theme.surface }}>
      <Text style={{ color: theme.label }}>{trail.name}</Text>
    </View>
  );
}
```

**Alternative (let the system resolve per-color):**

`PlatformColor('label')` and `PlatformColor('systemBackground')` resolve to the correct value for the current appearance without a manual theme object — see the semantic-colors rule.

Reference: [Expo — Color themes](https://docs.expo.dev/develop/user-interface/color-themes/)
