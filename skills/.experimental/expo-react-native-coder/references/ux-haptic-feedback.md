---
title: Add Haptic Feedback for User Actions
impact: MEDIUM
impactDescription: provides tactile confirmation of interactions
tags: ux, haptics, feedback, native-feel
---

## Add Haptic Feedback for User Actions

Use `expo-haptics` to provide tactile feedback on button presses, toggles, and other interactions for a more native feel.

**Incorrect (no haptic feedback):**

```typescript
<Pressable onPress={handleDelete}>
  <Text>Delete</Text>
</Pressable>
// No physical feedback - feels unresponsive
```

**Correct (haptic feedback on actions):**

```typescript
import * as Haptics from 'expo-haptics';
import { Pressable, Switch, Text, View } from 'react-native';
import { useState } from 'react';

export default function SettingsScreen() {
  const [enabled, setEnabled] = useState(false);

  // Light tap for regular buttons
  const handlePress = async () => {
    await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    // Do action
  };

  // Medium tap for toggles
  const handleToggle = async (value: boolean) => {
    await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    setEnabled(value);
  };

  // Success notification for completed actions
  const handleSave = async () => {
    await saveData();
    await Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
  };

  // Warning for destructive actions
  const handleDelete = async () => {
    await Haptics.notificationAsync(Haptics.NotificationFeedbackType.Warning);
    // Show confirmation dialog
  };

  // Selection change feedback
  const handleSelect = async () => {
    await Haptics.selectionAsync();
  };

  return (
    <View>
      <Pressable onPress={handlePress}>
        <Text>Regular Button</Text>
      </Pressable>

      <Switch value={enabled} onValueChange={handleToggle} />

      <Pressable onPress={handleSave}>
        <Text>Save</Text>
      </Pressable>

      <Pressable onPress={handleDelete}>
        <Text style={{ color: 'red' }}>Delete</Text>
      </Pressable>
    </View>
  );
}
```

**Feedback types:**
- `impactAsync`: Light, Medium, Heavy - for taps
- `notificationAsync`: Success, Warning, Error - for outcomes
- `selectionAsync`: For selection changes (pickers, etc.)

Reference: [Haptics - Expo Documentation](https://docs.expo.dev/versions/latest/sdk/haptics/)
