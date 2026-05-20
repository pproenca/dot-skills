---
title: Inset list content past the tab bar and home indicator
impact: MEDIUM-HIGH
impactDescription: prevents the last row hidden behind the tab bar
tags: layout, content-inset, lists, safe-area
---

## Inset list content past the tab bar and home indicator

A list that scrolls edge-to-edge under a translucent tab bar looks right while scrolling, but the final rows must be reachable above the bar and the home indicator — otherwise the last item sits permanently half-hidden and untappable. Add bottom content padding equal to the bottom safe-area inset (plus the bar height) so the list bottoms out cleanly.

**Incorrect (no bottom inset, last row trapped under the bar):**

```tsx
import { FlatList } from 'react-native';

// The last trail sits under the translucent tab bar and can't be fully tapped
function SavedTrailsScreen() {
  return <FlatList data={savedTrails} renderItem={renderTrailRow} />;
}
```

**Correct (bottom inset clears the bar and home indicator):**

```tsx
import { FlatList } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

function SavedTrailsScreen() {
  const insets = useSafeAreaInsets();
  return (
    <FlatList
      data={savedTrails}
      renderItem={renderTrailRow}
      // Last row clears the translucent bar and the home indicator
      contentContainerStyle={{ paddingBottom: insets.bottom + 16 }}
    />
  );
}
```

Reference: [React Native — ScrollView contentInsetAdjustmentBehavior](https://reactnative.dev/docs/scrollview#contentinsetadjustmentbehavior-ios)
