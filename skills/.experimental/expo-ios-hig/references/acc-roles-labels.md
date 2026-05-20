---
title: Label interactive and icon-only controls for VoiceOver
impact: MEDIUM-HIGH
impactDescription: enables VoiceOver to announce purpose and role
tags: acc, voiceover, accessibility-label, accessibility-role
---

## Label interactive and icon-only controls for VoiceOver

VoiceOver reads the accessibility tree, not the pixels. An icon-only button with no label is announced as nothing useful — the user hears "button" with no idea what it does — and a tappable `View` with no role isn't announced as actionable at all. Setting `accessibilityRole` and a concise `accessibilityLabel` lets VoiceOver say "Save trail, button," which is the difference between usable and unusable for screen-reader users.

**Incorrect (icon button with no label or role):**

```tsx
import { Pressable } from 'react-native';
import { SymbolView } from 'expo-symbols';

// VoiceOver announces "button" with no purpose — the glyph means nothing to it
function SaveButton() {
  return (
    <Pressable onPress={saveTrail}>
      <SymbolView name="bookmark" size={24} />
    </Pressable>
  );
}
```

**Correct (explicit role and label):**

```tsx
import { Pressable } from 'react-native';
import { SymbolView } from 'expo-symbols';

// VoiceOver announces "Save trail, button"
function SaveButton() {
  return (
    <Pressable onPress={saveTrail} accessibilityRole="button" accessibilityLabel="Save trail">
      <SymbolView name="bookmark" size={24} />
    </Pressable>
  );
}
```

Reference: [React Native — Accessibility](https://reactnative.dev/docs/accessibility)
