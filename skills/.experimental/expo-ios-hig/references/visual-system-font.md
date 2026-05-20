---
title: Use the system font for interface text
impact: MEDIUM-HIGH
impactDescription: enables San Francisco with optical sizing and tracking
tags: visual, typography, system-font, dynamic-type
---

## Use the system font for interface text

San Francisco — the iOS system font — applies optical sizing, per-size tracking, and weight rendering that Apple tuned for screens, and it is what every system surface around your app uses. Bundling a custom font for body and label text adds load time, ships glyphs that fall back inconsistently, and reads as off next to the navigation bar and keyboard. Use the system font (the React Native default, or `System`) for interface text and reserve custom fonts for display moments.

**Incorrect (custom font for all interface text):**

```tsx
import { Text } from 'react-native';

// Bundled font for every label fights the system chrome and adds startup cost
function TrailName({ trail }: { trail: Trail }) {
  return <Text style={{ fontFamily: 'Inter-Regular' }}>{trail.name}</Text>;
}
```

**Correct (system font for interface text):**

```tsx
import { Text } from 'react-native';

// System font: optical sizing, tuned tracking, matches surrounding iOS chrome
function TrailName({ trail }: { trail: Trail }) {
  return <Text style={{ fontWeight: '600' }}>{trail.name}</Text>;
}
```

**When NOT to use this pattern:**

- A deliberate brand display face on a hero or onboarding screen — scoped, not applied to every label.

Reference: [Apple HIG — Typography](https://developer.apple.com/design/human-interface-guidelines/typography)
