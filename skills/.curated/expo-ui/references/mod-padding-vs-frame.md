---
title: Use padding for Inner Space — frame for Outer Constraints
impact: HIGH
impactDescription: prevents double-counting space — padding adds inside the view's bounds, frame fixes total bounds
tags: mod, padding, frame, layout
---

## Use padding for Inner Space — frame for Outer Constraints

`padding` adds space *inside* a view's bounds, expanding the view to accommodate content plus padding. `frame` fixes the *outer* bounds, leaving content size to fit within. Using both unconditionally (or using `frame` when `padding` is intended) double-counts and produces views that are larger or smaller than expected.

**Incorrect (frame with hardcoded numbers — must be manually recomputed if label length changes):**

```tsx
import { Host, Button } from '@expo/ui/swift-ui';
import { frame, background, cornerRadius } from '@expo/ui/swift-ui/modifiers';

<Host matchContents>
  <Button
    label="Submit application"
    onPress={submit}
    modifiers={[frame({ width: 180, height: 44 }), background('#0A84FF'), cornerRadius(8)]}
  />
</Host>
```

**Correct (padding lets the label drive width — easier to maintain):**

```tsx
import { Host, Button } from '@expo/ui/swift-ui';
import { padding, background, cornerRadius, foregroundStyle } from '@expo/ui/swift-ui/modifiers';

<Host matchContents>
  <Button
    label="Submit application"
    onPress={submit}
    modifiers={[
      foregroundStyle('white'),
      padding({ horizontal: 24, vertical: 12 }),
      background('#0A84FF'),
      cornerRadius(8),
    ]}
  />
</Host>
```

**When NOT to use this pattern:**

- Fixed-size icons or controls that must align to a grid (toolbar items, tab bar icons). Use `frame` with concrete dimensions.

Reference: [padding modifier](https://developer.apple.com/documentation/swiftui/view/padding(_:))
