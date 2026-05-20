---
title: Size touch targets to at least 44pt
impact: HIGH
impactDescription: enables reliable taps with a 44pt minimum target
tags: touch, hit-target, accessibility, controls
---

## Size touch targets to at least 44pt

Apple's HIG sets 44x44pt as the minimum comfortable touch target because that is roughly the pad of a fingertip. A 20pt icon button is easy to miss, especially in motion or for users with limited dexterity, which produces the "I tapped it twice" frustration. When a control must look small, keep its visual size but expand the touchable area with `hitSlop` so the target stays 44pt.

**Incorrect (visual size equals a tiny touch target):**

```tsx
import { Pressable } from 'react-native';
import { SymbolView } from 'expo-symbols';

// A 20pt glyph yields a ~20pt target — frequently missed
function CloseButton() {
  return (
    <Pressable onPress={dismiss}>
      <SymbolView name="xmark" size={20} />
    </Pressable>
  );
}
```

**Correct (small glyph, 44pt touchable area):**

```tsx
import { Pressable } from 'react-native';
import { SymbolView } from 'expo-symbols';

// Glyph stays 20pt, but hitSlop expands the target to 44pt
function CloseButton() {
  return (
    <Pressable onPress={dismiss} hitSlop={12}>
      <SymbolView name="xmark" size={20} />
    </Pressable>
  );
}
```

Reference: [Apple HIG — Accessibility (buttons and controls)](https://developer.apple.com/design/human-interface-guidelines/accessibility)
