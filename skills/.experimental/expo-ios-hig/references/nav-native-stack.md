---
title: Use Expo Router's native Stack for screen hierarchy
impact: CRITICAL
impactDescription: preserves native push/pop, swipe-back, and Liquid Glass headers
tags: nav, expo-router, native-stack, navigation
---

## Use Expo Router's native Stack for screen hierarchy

A JavaScript-animated stack recreates the iOS transition on the JS thread, so it drops the interactive swipe-back edge gesture, the large-title collapse, and — on iOS 26 — the Liquid Glass header that the system applies to a real `UINavigationController`. The native stack inherits all of these from UIKit, which is the difference between an app that feels native and one that reads as a web wrapper.

**Incorrect (JS-thread card stack):**

```tsx
import { createStackNavigator } from '@react-navigation/stack';

const Stack = createStackNavigator();

// JS-animated cards: no swipe-back edge, no large-title collapse,
// header never adopts the iOS 26 Liquid Glass material
export function TrailsNavigator() {
  return (
    <Stack.Navigator screenOptions={{ headerStyle: { backgroundColor: '#ffffff' } }}>
      <Stack.Screen name="Trails" component={TrailsScreen} />
      <Stack.Screen name="TrailDetail" component={TrailDetailScreen} />
    </Stack.Navigator>
  );
}
```

**Correct (UIKit-backed native stack):**

```tsx
// app/(trails)/_layout.tsx
import { Stack } from 'expo-router';

// Native UINavigationController stack: real push/pop, interactive swipe-back,
// large-title collapse, and the system Liquid Glass header on iOS 26
export default function TrailsLayout() {
  return (
    <Stack>
      <Stack.Screen name="index" options={{ title: 'Trails' }} />
      <Stack.Screen name="[trailId]" options={{ title: 'Trail' }} />
    </Stack>
  );
}
```

Reference: [Expo Router — Stack](https://docs.expo.dev/router/advanced/stack/)
