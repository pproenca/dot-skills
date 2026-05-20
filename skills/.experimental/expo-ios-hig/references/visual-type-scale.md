---
title: Map text styles to the iOS type scale
impact: MEDIUM-HIGH
impactDescription: enables a hierarchy mapped to iOS text styles
tags: visual, typography, type-scale, hierarchy
---

## Map text styles to the iOS type scale

iOS expresses hierarchy through a defined set of text styles — Large Title, Title, Headline, Body, Subheadline, Caption — each with a size, weight, and line height that relate to one another. Picking arbitrary pixel sizes per screen produces inconsistent hierarchy and breaks the relationship between titles and body across the app. Define a small set of named styles mapped to the iOS scale and reuse them, so every screen speaks the same visual language.

**Incorrect (ad-hoc sizes per screen):**

```tsx
import { Text } from 'react-native';

// Arbitrary sizes that don't relate to each other or to system text styles
function TrailHeader({ trail }: { trail: Trail }) {
  return (
    <>
      <Text style={{ fontSize: 27, fontWeight: 'bold' }}>{trail.name}</Text>
      <Text style={{ fontSize: 13 }}>{trail.region}</Text>
    </>
  );
}
```

**Correct (named styles on the iOS scale):**

```tsx
import { Text } from 'react-native';

// Title and Subheadline drawn from a shared scale aligned to iOS text styles
function TrailHeader({ trail }: { trail: Trail }) {
  return (
    <>
      <Text style={textStyles.title}>{trail.name}</Text>
      <Text style={textStyles.subheadline}>{trail.region}</Text>
    </>
  );
}
```

Reference: [Apple HIG — Typography](https://developer.apple.com/design/human-interface-guidelines/typography)
