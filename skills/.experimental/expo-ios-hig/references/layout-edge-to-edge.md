---
title: Extend scrollable content under translucent bars
impact: HIGH
impactDescription: enables the scroll-edge translucency of system bars
tags: layout, edge-to-edge, scroll-view, liquid-glass
---

## Extend scrollable content under translucent bars

On iOS the navigation and tab bars are translucent and content is meant to scroll underneath them, which is what produces the blur-on-scroll and, on iOS 26, the Liquid Glass scroll-edge effect. Insetting the scroll view to start below an opaque bar wastes the safe area, kills the blur, and makes the bar look pasted on. Let content go edge-to-edge and ask the system to inset the scroll indicators automatically.

**Incorrect (manual top inset under an opaque bar):**

```tsx
import { ScrollView } from 'react-native';

// Content starts below the bar, so nothing scrolls under it and the bar never blurs
function TrailsScreen() {
  return (
    <ScrollView contentContainerStyle={{ paddingTop: 96 }}>
      <TrailList />
    </ScrollView>
  );
}
```

**Correct (content under the bar, system-managed insets):**

```tsx
import { ScrollView } from 'react-native';

// Content scrolls under the translucent bar; the system insets indicators and content
function TrailsScreen() {
  return (
    <ScrollView contentInsetAdjustmentBehavior="automatic">
      <TrailList />
    </ScrollView>
  );
}
```

Reference: [Apple HIG — Layout](https://developer.apple.com/design/human-interface-guidelines/layout)
