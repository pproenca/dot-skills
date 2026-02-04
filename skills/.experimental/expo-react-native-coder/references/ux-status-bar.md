---
title: Configure Status Bar Style Per Screen
impact: MEDIUM
impactDescription: matches status bar to screen design
tags: ux, status-bar, theming, style
---

## Configure Status Bar Style Per Screen

Use `expo-status-bar` to control the status bar appearance. Match the style to your screen's background color.

**Incorrect (ignoring status bar style):**

```typescript
// Dark background with dark status bar text - unreadable!
<View style={{ flex: 1, backgroundColor: '#1a1a1a' }}>
  <Text style={{ color: '#fff' }}>Content</Text>
</View>
```

**Correct (StatusBar component):**

```typescript
import { StatusBar } from 'expo-status-bar';
import { View, Text } from 'react-native';

// Dark background screen
export default function DarkScreen() {
  return (
    <View style={{ flex: 1, backgroundColor: '#1a1a1a' }}>
      <StatusBar style="light" />
      <Text style={{ color: '#fff' }}>White status bar on dark background</Text>
    </View>
  );
}

// Light background screen
export function LightScreen() {
  return (
    <View style={{ flex: 1, backgroundColor: '#ffffff' }}>
      <StatusBar style="dark" />
      <Text>Dark status bar on light background</Text>
    </View>
  );
}

// Auto style (based on system theme)
export function AutoScreen() {
  return (
    <View style={{ flex: 1 }}>
      <StatusBar style="auto" />
      <Text>Adapts to system theme</Text>
    </View>
  );
}
```

**Global configuration in layout:**

```typescript
// app/_layout.tsx
import { StatusBar } from 'expo-status-bar';
import { Stack } from 'expo-router';

export default function RootLayout() {
  return (
    <>
      <StatusBar style="auto" />
      <Stack />
    </>
  );
}
```

**Options:** `light` (white text), `dark` (black text), `auto` (based on theme)

Reference: [StatusBar - Expo Documentation](https://docs.expo.dev/versions/latest/sdk/status-bar/)
