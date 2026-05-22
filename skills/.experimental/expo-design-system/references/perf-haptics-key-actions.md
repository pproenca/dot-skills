---
title: Add Haptic Feedback to Confirmations and Toggles
impact: LOW-MEDIUM
impactDescription: maintains a native-feel response on consequential actions
tags: perf, haptics, expo-haptics, feedback
---

## Add Haptic Feedback to Confirmations and Toggles

On native iOS and Android, consequential actions answer with a tactile pulse; without it, cancelling an appointment feels identical to a no-op tap. A short `expo-haptics` impact tied to confirmations and toggles restores that native-feel response and signals that something important happened.

**Incorrect (no tactile feedback on a destructive confirm):**

```typescript
function confirmCancel(id: string) {
  cancelAppointment(id) // the tap produces no physical signal
}

<AppButton title="Cancel appointment" variant="danger" onPress={() => confirmCancel(id)} />
```

**Correct (impact feedback tied to the action):**

```typescript
import * as Haptics from 'expo-haptics'

async function confirmCancel(id: string) {
  await Haptics.notificationAsync(Haptics.NotificationFeedbackType.Warning)
  cancelAppointment(id)
}

<AppButton title="Cancel appointment" variant="danger" onPress={() => confirmCancel(id)} />
// The warning haptic marks a consequential action, matching native platform behavior.
```

**Web:** `expo-haptics` is a no-op on web, so this feedback silently disappears there — pair it with a visible cue. See [`platform-guard-native-only`](platform-guard-native-only.md).

Reference: [expo-haptics](https://docs.expo.dev/versions/latest/sdk/haptics/)
