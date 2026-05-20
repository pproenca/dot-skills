---
title: Use the native alert for confirmations
impact: HIGH
impactDescription: preserves native alert appearance, haptics, and accessibility
tags: native, alert, confirmation, destructive
---

## Use the native alert for confirmations

A custom JS-rendered dialog has to reimplement the blurred backdrop, the spring presentation, button ordering conventions, destructive-red styling, VoiceOver focus trapping, and the haptic that fires on appearance — and it usually gets several of these wrong. The platform `Alert` inherits all of it and guarantees the layout users already know (cancel on the left, default action bold on the right).

**Incorrect (custom modal as a confirmation):**

```tsx
import { Modal, View, Text, Pressable } from 'react-native';

// Reimplements backdrop, button order, destructive styling, and focus trapping —
// and breaks VoiceOver focus on present
<Modal transparent visible={confirming} animationType="fade">
  <View style={styles.backdrop}>
    <Text>Delete this saved trail?</Text>
    <Pressable onPress={deleteTrail}><Text>Delete</Text></Pressable>
    <Pressable onPress={cancel}><Text>Cancel</Text></Pressable>
  </View>
</Modal>
```

**Correct (system Alert with destructive role):**

```tsx
import { Alert } from 'react-native';

// Native alert: correct button order, red destructive style, VoiceOver focus, haptic
function confirmDelete(trailId: string) {
  Alert.alert('Delete saved trail?', 'This removes it from your saved list.', [
    { text: 'Cancel', style: 'cancel' },
    { text: 'Delete', style: 'destructive', onPress: () => deleteTrail(trailId) },
  ]);
}
```

**When NOT to use this pattern:**

- Choosing among several actions — that is an action sheet, not an alert. Reserve alerts for blocking, critical decisions.

Reference: [Apple HIG — Alerts](https://developer.apple.com/design/human-interface-guidelines/alerts)
