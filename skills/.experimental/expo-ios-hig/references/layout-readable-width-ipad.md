---
title: Constrain reading width on iPad and large screens
impact: MEDIUM
impactDescription: prevents over-stretched lines on iPad
tags: layout, ipad, readable-width, adaptivity
---

## Constrain reading width on iPad and large screens

A phone layout stretched full-width on iPad produces lines of text far past the comfortable reading measure and forms whose fields span the whole screen, both of which feel like a blown-up phone app rather than an iPad app. Cap the content width (roughly 700pt for body text) and center it, or move to a multi-column layout, so large screens earn their space.

**Incorrect (phone layout stretched edge-to-edge):**

```tsx
import { ScrollView, Text } from 'react-native';

// On iPad each line runs the full width — well past a readable measure
function TrailDescription({ trail }: { trail: Trail }) {
  return (
    <ScrollView contentContainerStyle={{ padding: 16 }}>
      <Text>{trail.longDescription}</Text>
    </ScrollView>
  );
}
```

**Correct (centered, width-capped reading column):**

```tsx
import { ScrollView, Text } from 'react-native';

// Body text caps at a readable measure and centers on wide screens
function TrailDescription({ trail }: { trail: Trail }) {
  return (
    <ScrollView contentContainerStyle={{ padding: 16, alignItems: 'center' }}>
      <Text style={{ maxWidth: 700, width: '100%' }}>{trail.longDescription}</Text>
    </ScrollView>
  );
}
```

Reference: [Apple HIG — Layout](https://developer.apple.com/design/human-interface-guidelines/layout)
