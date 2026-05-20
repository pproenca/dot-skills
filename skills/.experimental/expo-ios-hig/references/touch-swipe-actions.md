---
title: Offer swipe actions on list rows
impact: MEDIUM-HIGH
impactDescription: eliminates an extra menu step for delete and archive
tags: touch, swipe-actions, gesture-handler, lists
---

## Offer swipe actions on list rows

Swiping a row to reveal Delete or Archive is a core iOS interaction users learn from Mail, Messages, and Reminders. Burying those actions behind a long-press menu or a separate edit mode makes common operations slower than the platform norm. `react-native-gesture-handler`'s `Swipeable` renders the gesture on the UI thread with the expected snap and color reveal.

**Incorrect (destructive action hidden behind a menu):**

```tsx
import { Pressable, Text } from 'react-native';

// Deleting requires opening a menu first — slower than a swipe and non-standard
function SavedTrailRow({ trail }: { trail: Trail }) {
  return (
    <Pressable onLongPress={() => openRowMenu(trail.id)}>
      <Text>{trail.name}</Text>
    </Pressable>
  );
}
```

**Correct (swipe-to-reveal actions):**

```tsx
import { Swipeable } from 'react-native-gesture-handler';
import { Pressable, Text } from 'react-native';

// Swipe left reveals a red Delete, matching Mail and Reminders
function SavedTrailRow({ trail }: { trail: Trail }) {
  const renderRight = () => (
    <Pressable style={styles.deleteAction} onPress={() => deleteTrail(trail.id)}>
      <Text style={styles.deleteLabel}>Delete</Text>
    </Pressable>
  );
  return (
    <Swipeable renderRightActions={renderRight}>
      <Text style={styles.row}>{trail.name}</Text>
    </Swipeable>
  );
}
```

Reference: [React Native Gesture Handler — Swipeable](https://docs.swmansion.com/react-native-gesture-handler/docs/components/reanimated_swipeable/)
