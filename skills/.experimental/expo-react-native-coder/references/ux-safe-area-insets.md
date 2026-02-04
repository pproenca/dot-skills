---
title: Use SafeAreaView for Notches and System UI
impact: HIGH
impactDescription: prevents content from being hidden by device UI
tags: ux, safe-area, notch, status-bar
---

## Use SafeAreaView for Notches and System UI

Use `react-native-safe-area-context` to avoid content being hidden by notches, status bars, and home indicators.

**Incorrect (content hidden by notch):**

```typescript
import { View, Text } from 'react-native';

export default function Screen() {
  return (
    <View style={{ flex: 1 }}>
      <Text>This text may be behind the notch!</Text>
    </View>
  );
}
```

**Correct (SafeAreaView wraps content):**

```typescript
import { SafeAreaView } from 'react-native-safe-area-context';
import { Text } from 'react-native';

export default function Screen() {
  return (
    <SafeAreaView style={{ flex: 1 }}>
      <Text>This text is safely positioned</Text>
    </SafeAreaView>
  );
}
```

**Alternative with useSafeAreaInsets hook:**

```typescript
import { View, Text, StyleSheet } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

export default function Screen() {
  const insets = useSafeAreaInsets();

  return (
    <View style={[styles.container, { paddingTop: insets.top, paddingBottom: insets.bottom }]}>
      <Text>Custom padding based on insets</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
});
```

**When to use each:**
- `SafeAreaView`: Simple screens with standard layout
- `useSafeAreaInsets`: Custom layouts, sticky headers, or when you need different insets for different edges

**Note:** Expo Router projects include `react-native-safe-area-context` by default.

Reference: [Safe areas - Expo Documentation](https://docs.expo.dev/develop/user-interface/safe-areas/)
