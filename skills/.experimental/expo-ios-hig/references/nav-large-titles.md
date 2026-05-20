---
title: Enable large titles on top-level screens
impact: HIGH
impactDescription: enables large-title collapse and the scroll-edge appearance
tags: nav, large-title, navigation-bar, scroll-edge
---

## Enable large titles on top-level screens

iOS top-level lists open with a large title that shrinks into a standard inline title as the user scrolls, and the bar switches from transparent (over content) to the blurred scroll-edge appearance. This motion orients the user and is a strong native signal. A title rendered as a `Text` in the screen body neither collapses nor blurs, so the screen reads as a generic cross-platform view.

**Incorrect (static title in the body):**

```tsx
import { Stack } from 'expo-router';
import { ScrollView, Text } from 'react-native';

export default function TrailsScreen() {
  return (
    <>
      <Stack.Screen options={{ headerShown: false }} />
      {/* Body title never collapses on scroll and the bar never blurs */}
      <ScrollView>
        <Text style={{ fontSize: 34, fontWeight: '700' }}>Trails</Text>
        <TrailList />
      </ScrollView>
    </>
  );
}
```

**Correct (system large title that collapses):**

```tsx
import { Stack } from 'expo-router';
import { ScrollView } from 'react-native';

export default function TrailsScreen() {
  return (
    <>
      {/* System large title collapses on scroll; bar adopts the scroll-edge blur */}
      <Stack.Screen options={{ title: 'Trails', headerLargeTitle: true }} />
      <ScrollView contentInsetAdjustmentBehavior="automatic">
        <TrailList />
      </ScrollView>
    </>
  );
}
```

**Warning (collapse needs a direct-child scroll view):**

The large title only collapses on scroll when the `ScrollView` or `FlatList` is the direct first child of the screen. Wrapping it in another `View` silently breaks the collapse, leaving the title permanently expanded.

**When NOT to use this pattern:**

- Detail screens deep in a stack — use a standard inline title there; large titles belong on the root of each tab.

Reference: [Apple HIG — Navigation bars](https://developer.apple.com/design/human-interface-guidelines/navigation-bars)
