---
title: Request permissions just in time with a rationale
impact: MEDIUM
impactDescription: enables higher opt-in with just-in-time prompts
tags: system, permissions, privacy, onboarding
---

## Request permissions just in time with a rationale

The system permission prompt can be shown only once — if the user denies it, you cannot ask again from inside the app. Firing every prompt at launch, before the user understands why, gets predictable denials and burns that one chance. Request each permission at the moment it is needed, after a short in-app explanation of what it unlocks, and write an honest `NSLocationWhenInUseUsageDescription` (and friends) so the system dialog states the real reason.

**Incorrect (request everything on launch):**

```tsx
import * as Location from 'expo-location';
import * as Notifications from 'expo-notifications';

// Fires both system prompts at startup with no context — most users deny
async function onAppStart() {
  await Location.requestForegroundPermissionsAsync();
  await Notifications.requestPermissionsAsync();
}
```

**Correct (just-in-time, after a rationale):**

```tsx
import * as Location from 'expo-location';

// Asked only when the user taps "Trails near me", after explaining why
async function onUseTrailsNearMe() {
  await explainLocationUse(); // brief in-app screen describing the benefit
  const { status } = await Location.requestForegroundPermissionsAsync();
  if (status === 'granted') showNearbyTrails();
}
```

Reference: [Apple HIG — Privacy](https://developer.apple.com/design/human-interface-guidelines/privacy)
