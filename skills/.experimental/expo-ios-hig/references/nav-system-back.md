---
title: Keep the system back button and swipe-back gesture
impact: HIGH
impactDescription: preserves the interactive swipe-back edge gesture
tags: nav, back-gesture, navigation-bar, gestures
---

## Keep the system back button and swipe-back gesture

The left-edge swipe-back gesture is one of the most-used interactions on iOS, and it is wired to the navigation bar's back button. Replacing the back button with a custom header-left control, or setting `gestureEnabled: false` to "simplify" a screen, silently disables that gesture and forces users to reach for a tiny target at the top of the screen. Keep the system back button; customize its label, not its existence.

**Incorrect (custom back control disables the gesture):**

```tsx
import { Stack } from 'expo-router';
import { Pressable, Text } from 'react-native';

// Replacing headerLeft drops the system back button, and the edge
// swipe-back gesture goes with it
<Stack.Screen
  options={{
    headerLeft: () => (
      <Pressable onPress={() => router.back()}><Text>Back</Text></Pressable>
    ),
    gestureEnabled: false,
  }}
/>
```

**Correct (keep the native back button and gesture):**

```tsx
import { Stack } from 'expo-router';

// System back button stays, so the edge swipe-back keeps working;
// only the label is customized
<Stack.Screen options={{ headerBackTitle: 'Trails' }} />
```

**When NOT to use this pattern:**

- A modal mid-task with unsaved changes — there, intercept dismissal to confirm, rather than removing the affordance entirely.

Reference: [Apple HIG — Navigation bars](https://developer.apple.com/design/human-interface-guidelines/navigation-bars)
