---
title: Use semantic system colors instead of hardcoded hex
impact: HIGH
impactDescription: enables colors that track appearance and contrast
tags: visual, platform-color, semantic-colors, dark-mode
---

## Use semantic system colors instead of hardcoded hex

iOS ships a palette of semantic colors — `label`, `secondaryLabel`, `systemBackground`, `separator`, `systemBlue` — that automatically resolve to the right value for light mode, dark mode, increased contrast, and elevation. Hardcoded hex values are frozen: they look correct in one appearance and wrong in the others, and they ignore the user's accessibility contrast setting. `PlatformColor` binds to the live system color so every surface stays correct.

**Incorrect (frozen hex values):**

```tsx
import { View, Text } from 'react-native';

// #8e8e93 is the light-mode secondary label; it's wrong in dark mode and high contrast
function TrailMeta({ trail }: { trail: Trail }) {
  return (
    <View style={{ backgroundColor: '#ffffff' }}>
      <Text style={{ color: '#8e8e93' }}>{trail.distanceLabel}</Text>
    </View>
  );
}
```

**Correct (semantic colors via PlatformColor):**

```tsx
import { View, Text, PlatformColor } from 'react-native';

// System colors resolve per appearance, elevation, and contrast setting
function TrailMeta({ trail }: { trail: Trail }) {
  return (
    <View style={{ backgroundColor: PlatformColor('systemBackground') }}>
      <Text style={{ color: PlatformColor('secondaryLabel') }}>{trail.distanceLabel}</Text>
    </View>
  );
}
```

**When NOT to use this pattern:**

- Brand colors that must stay constant across appearances — define those explicitly, but still provide a dark variant.

Reference: [React Native — PlatformColor](https://reactnative.dev/docs/platformcolor) · [Apple HIG — Color](https://developer.apple.com/design/human-interface-guidelines/color)
