---
title: Share through the system share sheet
impact: MEDIUM
impactDescription: enables the system share sheet and its extensions
tags: system, share-sheet, activity-view, share
---

## Share through the system share sheet

The iOS share sheet is where users expect sharing to happen: it lists their AirDrop devices, Messages, installed app extensions, and copy/save actions, and it remembers frequent recipients. A custom "share" screen with a hand-picked set of buttons can't reach AirDrop or third-party extensions and ignores the user's habits. Use the `Share` API (or `ShareLink` in `@expo/ui`) to present the real activity view.

**Incorrect (custom share screen with fixed buttons):**

```tsx
import { View, Pressable, Text } from 'react-native';

// A fixed list: no AirDrop, no app extensions, no Messages, no recents
function ShareTrailScreen({ trail }: { trail: Trail }) {
  return (
    <View>
      <Pressable onPress={() => copyLink(trail)}><Text>Copy link</Text></Pressable>
      <Pressable onPress={() => emailTrail(trail)}><Text>Email</Text></Pressable>
    </View>
  );
}
```

**Correct (system share sheet):**

```tsx
import { Share } from 'react-native';

// Real activity view: AirDrop, Messages, extensions, copy, and recents
function shareTrail(trail: Trail) {
  Share.share({
    title: trail.name,
    url: `https://trailhead.app/trails/${trail.id}`,
    message: `Check out ${trail.name} on Trailhead`,
  });
}
```

Reference: [React Native — Share](https://reactnative.dev/docs/share)
