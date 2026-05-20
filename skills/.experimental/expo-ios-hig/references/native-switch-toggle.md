---
title: Use the platform Switch for boolean settings
impact: MEDIUM-HIGH
impactDescription: preserves correct toggle size, animation, and accessibility
tags: native, switch, toggle, settings
---

## Use the platform Switch for boolean settings

The iOS switch has a specific size, thumb spring animation, green "on" tint, selection haptic, and a `switch` accessibility trait that VoiceOver announces as "on/off". A custom toggle built from an animated `View` reproduces the look but rarely the haptic, the exact timing, or the accessibility trait — so it reads as almost-right, which is worse than obviously custom. Use the platform `Switch`.

**Incorrect (custom animated toggle):**

```tsx
import { Pressable, Animated } from 'react-native';

// Looks like a switch but lacks the selection haptic and the switch a11y trait
function OfflineToggle({ on, onToggle }: ToggleProps) {
  return (
    <Pressable onPress={onToggle} style={styles.track}>
      <Animated.View style={[styles.thumb, on && styles.thumbOn]} />
    </Pressable>
  );
}
```

**Correct (platform Switch):**

```tsx
import { Switch } from 'react-native';

// Native switch: correct size, thumb spring, tint, haptic, and switch a11y trait
function OfflineToggle({ on, onToggle }: ToggleProps) {
  return <Switch value={on} onValueChange={onToggle} />;
}
```

Reference: [Apple HIG — Toggles](https://developer.apple.com/design/human-interface-guidelines/toggles)
