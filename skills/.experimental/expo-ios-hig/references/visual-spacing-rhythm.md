---
title: Derive spacing from a single base unit
impact: MEDIUM
impactDescription: enables a consistent grid from one base unit
tags: visual, spacing, layout-grid, tokens
---

## Derive spacing from a single base unit

Consistent spacing is what makes a layout feel calm and intentional rather than assembled by hand. When every margin and gap is a separate arbitrary number (11 here, 13 there, 17 somewhere else), the eye reads the inconsistency as sloppiness even when it can't name it. Derive all spacing from one base unit (commonly 8pt with a 4pt half-step) exposed as tokens, so every measurement relates to every other.

**Incorrect (unrelated hardcoded numbers):**

```tsx
import { View } from 'react-native';

// Spacing values that don't relate to a base unit; the rhythm reads as random
function TrailCard({ trail }: { trail: Trail }) {
  return (
    <View style={{ padding: 13, marginBottom: 11, gap: 7 }}>
      <TrailThumbnail uri={trail.image} />
    </View>
  );
}
```

**Correct (tokens from one base unit):**

```tsx
import { View } from 'react-native';

// All spacing steps off an 8pt base (space.sm = 8, space.md = 16)
function TrailCard({ trail }: { trail: Trail }) {
  return (
    <View style={{ padding: space.md, marginBottom: space.sm, gap: space.xs }}>
      <TrailThumbnail uri={trail.image} />
    </View>
  );
}
```

Reference: [Apple HIG — Layout](https://developer.apple.com/design/human-interface-guidelines/layout)
