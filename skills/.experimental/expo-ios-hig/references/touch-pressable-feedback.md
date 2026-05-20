---
title: Give every control immediate press feedback
impact: HIGH
impactDescription: prevents the double-tap from an unconfirmed press
tags: touch, pressable, feedback, controls
---

## Give every control immediate press feedback

On iOS, tappable things respond the instant a finger lands — they dim, highlight, or scale — which confirms the touch registered before the action completes. A bare `View` with `onPress`, or a `TouchableWithoutFeedback`, fires the action but shows nothing on press, so the user can't tell whether the tap landed and often taps again. Use `Pressable` and render a pressed state.

**Incorrect (no visual response on press):**

```tsx
import { TouchableWithoutFeedback, View, Text } from 'react-native';

// Nothing changes on touch-down, so the tap feels unregistered
function StartHikeButton() {
  return (
    <TouchableWithoutFeedback onPress={startHike}>
      <View style={styles.button}><Text>Start hike</Text></View>
    </TouchableWithoutFeedback>
  );
}
```

**Correct (pressed state confirms the touch):**

```tsx
import { Pressable, Text } from 'react-native';

// Dims on touch-down, so the user sees the tap land immediately
function StartHikeButton() {
  return (
    <Pressable onPress={startHike} style={({ pressed }) => [styles.button, pressed && { opacity: 0.6 }]}>
      <Text>Start hike</Text>
    </Pressable>
  );
}
```

Reference: [React Native — Pressable](https://reactnative.dev/docs/pressable)
