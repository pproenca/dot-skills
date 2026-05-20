---
title: Expose control state to assistive technology
impact: MEDIUM
impactDescription: enables VoiceOver to announce state and outcome
tags: acc, accessibility-state, accessibility-hint, voiceover
---

## Expose control state to assistive technology

A control's selected, disabled, or busy state is obvious sighted users but invisible to VoiceOver unless you report it through `accessibilityState`. A filter chip that looks selected but doesn't announce "selected," or a disabled button that VoiceOver still says is tappable, misleads screen-reader users. Set `accessibilityState` to mirror the visual state, and add an `accessibilityHint` when the result of an action isn't obvious from its label.

**Incorrect (visual state only):**

```tsx
import { Pressable, Text } from 'react-native';

// Looks selected, but VoiceOver never announces the selected state
function DifficultyChip({ label, selected, onPress }: ChipProps) {
  return (
    <Pressable onPress={onPress} style={[styles.chip, selected && styles.chipSelected]}>
      <Text>{label}</Text>
    </Pressable>
  );
}
```

**Correct (state reported to VoiceOver):**

```tsx
import { Pressable, Text } from 'react-native';

// VoiceOver announces "Hard, selected" and the hint clarifies the effect
function DifficultyChip({ label, selected, onPress }: ChipProps) {
  return (
    <Pressable
      onPress={onPress}
      style={[styles.chip, selected && styles.chipSelected]}
      accessibilityRole="button"
      accessibilityState={{ selected }}
      accessibilityHint="Filters trails by this difficulty"
    >
      <Text>{label}</Text>
    </Pressable>
  );
}
```

Reference: [React Native — Accessibility](https://reactnative.dev/docs/accessibility)
