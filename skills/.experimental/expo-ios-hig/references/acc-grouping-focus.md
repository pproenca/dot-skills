---
title: Group related elements for a logical focus order
impact: MEDIUM
impactDescription: enables a logical, predictable focus order
tags: acc, grouping, focus-order, voiceover
---

## Group related elements for a logical focus order

By default VoiceOver focuses each `Text` and image separately, so a card with a title, distance, and difficulty becomes three disconnected stops the user must swipe through before understanding they belong together. Marking the card container as `accessible` collapses it into one focusable element with a combined label, so VoiceOver reads "Eagle Ridge Trail, 8 km, hard" in a single, logical stop that matches the visual grouping.

**Incorrect (every child is a separate stop):**

```tsx
import { Pressable, Text } from 'react-native';

// VoiceOver stops on each line separately, fragmenting one card into three swipes
function TrailRow({ trail }: { trail: Trail }) {
  return (
    <Pressable onPress={() => openTrail(trail.id)}>
      <Text>{trail.name}</Text>
      <Text>{trail.distanceLabel}</Text>
      <Text>{trail.difficulty}</Text>
    </Pressable>
  );
}
```

**Correct (one grouped, focusable element):**

```tsx
import { Pressable, Text } from 'react-native';

// One focus stop with a combined label that matches the visual grouping
function TrailRow({ trail }: { trail: Trail }) {
  return (
    <Pressable
      onPress={() => openTrail(trail.id)}
      accessible
      accessibilityRole="button"
      accessibilityLabel={`${trail.name}, ${trail.distanceLabel}, ${trail.difficulty}`}
    >
      <Text>{trail.name}</Text>
      <Text>{trail.distanceLabel}</Text>
      <Text>{trail.difficulty}</Text>
    </Pressable>
  );
}
```

Reference: [React Native — Accessibility](https://reactnative.dev/docs/accessibility)
