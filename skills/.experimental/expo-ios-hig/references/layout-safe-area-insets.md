---
title: Respect safe-area insets with the safe-area context
impact: HIGH
impactDescription: prevents content clipped by the notch and home indicator
tags: layout, safe-area, insets, adaptivity
---

## Respect safe-area insets with the safe-area context

The status bar, Dynamic Island, and home indicator carve into the screen, and those regions differ across every device. Hardcoding top or bottom padding gets one device right and clips content or floats it awkwardly on the rest. `react-native-safe-area-context` reports the live insets for the current device and orientation, so a single layout adapts everywhere — and `SafeAreaView` applies them declaratively.

**Incorrect (hardcoded device-specific padding):**

```tsx
import { View } from 'react-native';

// 44/34 are correct on one phone and wrong on every other device and orientation
function TrailDetailScreen() {
  return <View style={{ paddingTop: 44, paddingBottom: 34 }}><TrailHeader /></View>;
}
```

**Correct (live insets from the safe-area context):**

```tsx
import { useSafeAreaInsets } from 'react-native-safe-area-context';

// Real insets for this device and orientation, reported by the system
function TrailDetailScreen() {
  const insets = useSafeAreaInsets();
  return (
    <View style={{ paddingTop: insets.top, paddingBottom: insets.bottom }}>
      <TrailHeader />
    </View>
  );
}
```

**When NOT to use this pattern:**

- Screens hosted in a native stack/tab with headers already applied — the navigator handles top/bottom insets; applying them again double-pads.

Reference: [Expo — Safe areas](https://docs.expo.dev/develop/user-interface/safe-areas/)
