---
title: Pair haptics with meaningful outcomes
impact: MEDIUM
impactDescription: prevents overuse that dulls the Taptic signal
tags: touch, haptics, expo-haptics, feedback
---

## Pair haptics with meaningful outcomes

iOS uses haptics sparingly and meaningfully: a success notification taps differently from a warning, and selection ticks accompany picker changes. Firing a heavy impact on every button tap trains users to ignore it and drains the Taptic Engine's signal value. Reserve `expo-haptics` for outcomes — a save succeeded, a destructive action fired, a selection changed — and match the haptic type to the meaning.

**Incorrect (heavy impact on every tap):**

```tsx
import * as Haptics from 'expo-haptics';

// Buzzes on every press regardless of outcome, so the signal becomes noise
function onAnyButtonPress() {
  Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Heavy);
  handlePress();
}
```

**Correct (notification haptic matched to the outcome):**

```tsx
import * as Haptics from 'expo-haptics';

// Success haptic only when the save actually succeeds; failure gets the error type
async function saveTrail(trail: Trail) {
  try {
    await api.saveTrail(trail);
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
  } catch {
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Error);
  }
}
```

Reference: [Expo — Haptics (expo-haptics)](https://docs.expo.dev/versions/latest/sdk/haptics/)
