---
title: Guard Native-Only APIs Behind Platform Checks With Web Fallbacks
impact: CRITICAL
impactDescription: prevents native-only calls from silently no-opping with no feedback on web
tags: platform, web, haptics, fallback
---

## Guard Native-Only APIs Behind Platform Checks With Web Fallbacks

`expo-haptics`, blur views, and other native modules silently no-op on web, so feedback the design relies on simply vanishes there. Routing native-only effects through one design-system helper that branches on `Platform.OS` keeps a single call site while giving web an equivalent cue — a toast or an `aria-live` announcement — instead of nothing.

**Incorrect (haptic is the only confirmation — gone on web):**

```typescript
import * as Haptics from 'expo-haptics'

async function confirmCancel(id: string) {
  await Haptics.notificationAsync(Haptics.NotificationFeedbackType.Warning)
  cancelAppointment(id)
}
// On web the haptic no-ops, so a cancelled appointment gives the user no feedback at all.
```

**Correct (one helper, platform-appropriate feedback):**

```typescript
import { Platform } from 'react-native'
import * as Haptics from 'expo-haptics'

async function signalWarning() {
  if (Platform.OS === 'web') return announce('Appointment cancelled') // design-system aria-live cue
  await Haptics.notificationAsync(Haptics.NotificationFeedbackType.Warning)
}

async function confirmCancel(id: string) {
  await signalWarning()
  cancelAppointment(id)
}
```

Reference: [Platform-specific code (React Native)](https://reactnative.dev/docs/platform-specific-code)
