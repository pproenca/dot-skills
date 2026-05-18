---
title: Order Modifiers from Inside-Out — Each Wraps the Previous
impact: CRITICAL
impactDescription: prevents visually wrong layering — padding-then-background paints inside the padding, background-then-padding paints the padding
tags: mod, modifiers, order, composition
---

## Order Modifiers from Inside-Out — Each Wraps the Previous

SwiftUI modifiers are applied in array order — each modifier wraps the previous result. `padding` then `background` paints the background *outside* the padding (full bleed). `background` then `padding` paints the background *under* the content but the padding pushes the content outside the painted area. Modifier order is semantically meaningful, not just stylistic.

**Incorrect (padding outside background — content overflows the painted shape):**

```tsx
import { Host, Text } from '@expo/ui/swift-ui';
import { background, padding, cornerRadius } from '@expo/ui/swift-ui/modifiers';

<Host matchContents>
  <Text modifiers={[padding({ all: 12 }), background('#0A84FF'), cornerRadius(8)]}>
    Premium
  </Text>
</Host>
```

**Correct (background inside padding — pill-shaped tag fits the text):**

```tsx
import { Host, Text } from '@expo/ui/swift-ui';
import { background, padding, cornerRadius, foregroundStyle } from '@expo/ui/swift-ui/modifiers';

<Host matchContents>
  <Text
    modifiers={[
      foregroundStyle('white'),
      padding({ horizontal: 12, vertical: 6 }),
      background('#0A84FF'),
      cornerRadius(8),
    ]}>
    Premium
  </Text>
</Host>
```

**When NOT to use this pattern:**

- Modifiers that don't paint or size (e.g., `disabled`, `accessibilityLabel`) are order-insensitive. Place them anywhere.

Reference: [SwiftUI view modifiers](https://developer.apple.com/documentation/swiftui/viewmodifier)
