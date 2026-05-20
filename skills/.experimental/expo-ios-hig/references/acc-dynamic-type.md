---
title: Let text scale with Dynamic Type
impact: MEDIUM-HIGH
impactDescription: enables text scaling up to 310% for low vision
tags: acc, dynamic-type, font-scaling, typography
---

## Let text scale with Dynamic Type

Many users raise the system text size because they cannot read the default, and iOS expects apps to honor that. Setting `allowFontScaling={false}` to protect a layout breaks the app for exactly those users — the text stays small and unreadable. Leave scaling on and instead cap it with `maxFontSizeMultiplier` where a layout genuinely can't absorb the largest accessibility sizes, so text still grows but within bounds you control.

**Incorrect (disable scaling to protect the layout):**

```tsx
import { Text } from 'react-native';

// Freezes text at the default size — unreadable for users who enabled larger text
function TrailName({ trail }: { trail: Trail }) {
  return <Text allowFontScaling={false} style={{ fontSize: 17 }}>{trail.name}</Text>;
}
```

**Correct (allow scaling, cap the multiplier):**

```tsx
import { Text } from 'react-native';

// Text scales with the user's setting, capped where the row can't grow further
function TrailName({ trail }: { trail: Trail }) {
  return <Text maxFontSizeMultiplier={1.8} style={{ fontSize: 17 }}>{trail.name}</Text>;
}
```

Reference: [Apple HIG — Typography (Dynamic Type)](https://developer.apple.com/design/human-interface-guidelines/typography)
