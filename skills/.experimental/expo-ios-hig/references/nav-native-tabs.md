---
title: Adopt native tabs for top-level sections
impact: CRITICAL
impactDescription: enables the system tab bar with SF Symbols and Liquid Glass
tags: nav, expo-router, native-tabs, tab-bar
---

## Adopt native tabs for top-level sections

A hand-rolled tab bar — a row of `Pressable`s pinned to the bottom — misses everything the system `UITabBar` provides: the translucent material that becomes Liquid Glass on iOS 26, scroll-to-top on re-tap of the active tab, badge support, the minimize-on-scroll behavior, and correct safe-area handling. Native tabs render the real control and accept SF Symbols directly.

**Incorrect (custom view tab bar):**

```tsx
import { View, Pressable, Text } from 'react-native';

// Opaque custom bar: no Liquid Glass, no scroll-to-top, no badges,
// and it overlaps content because it ignores the safe area
function TabBar({ active, onSelect }: TabBarProps) {
  return (
    <View style={{ position: 'absolute', bottom: 0, flexDirection: 'row' }}>
      <Pressable onPress={() => onSelect('trails')}><Text>Trails</Text></Pressable>
      <Pressable onPress={() => onSelect('saved')}><Text>Saved</Text></Pressable>
    </View>
  );
}
```

**Correct (system UITabBar via native tabs):**

```tsx
// app/_layout.tsx
import { NativeTabs, Icon, Label } from 'expo-router/unstable-native-tabs';

export default function TabsLayout() {
  return (
    <NativeTabs>
      <NativeTabs.Trigger name="trails">
        <Label>Trails</Label>
        <Icon sf="figure.hiking" />
      </NativeTabs.Trigger>
      <NativeTabs.Trigger name="saved">
        <Label>Saved</Label>
        <Icon sf="bookmark.fill" />
      </NativeTabs.Trigger>
    </NativeTabs>
  );
}
```

**When NOT to use this pattern:**

- Native tabs is a beta API (Expo SDK 55+); pin your SDK and test on a device before shipping.
- A heavily branded bottom bar that intentionally breaks platform convention — but expect to lose the system behaviors above.

Reference: [Expo Router — Native tabs](https://docs.expo.dev/router/advanced/native-tabs/)
