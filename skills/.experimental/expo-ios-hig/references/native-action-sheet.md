---
title: Use an action sheet to choose among actions
impact: HIGH
impactDescription: enables the system action sheet with destructive styling
tags: native, action-sheet, actionsheetios, modality
---

## Use an action sheet to choose among actions

When a user picks one action from a short list tied to a specific item (Share, Duplicate, Delete), iOS uses an action sheet anchored to the bottom on iPhone, with the destructive option in red and Cancel separated below. A custom bottom popover of `Pressable`s misses the anchoring rules, the destructive styling, the swipe-to-dismiss, and the VoiceOver grouping. `ActionSheetIOS` renders the system control.

**Incorrect (custom bottom list of buttons):**

```tsx
import { View, Pressable, Text } from 'react-native';

// Custom sheet: no destructive styling, no separated Cancel, no swipe-to-dismiss
function TrailActions() {
  return (
    <View style={styles.sheet}>
      <Pressable onPress={shareTrail}><Text>Share</Text></Pressable>
      <Pressable onPress={deleteTrail}><Text>Delete</Text></Pressable>
      <Pressable onPress={close}><Text>Cancel</Text></Pressable>
    </View>
  );
}
```

**Correct (system action sheet):**

```tsx
import { ActionSheetIOS } from 'react-native';

// System sheet: red destructive option, separated Cancel, native dismissal
function showTrailActions() {
  ActionSheetIOS.showActionSheetWithOptions(
    { options: ['Cancel', 'Share', 'Delete'], destructiveButtonIndex: 2, cancelButtonIndex: 0 },
    (index) => {
      if (index === 1) shareTrail();
      if (index === 2) deleteTrail();
    },
  );
}
```

**Alternative (cross-platform):**

For a single component that also renders correctly on Android, use `@expo/ui`'s presentation surfaces rather than `ActionSheetIOS`, which is iOS-only.

Reference: [Apple HIG — Action sheets](https://developer.apple.com/design/human-interface-guidelines/action-sheets)
