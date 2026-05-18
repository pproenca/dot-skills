---
title: Use frame for Explicit Sizing — fixedSize to Opt Out of Flex
impact: HIGH
impactDescription: prevents the wrong sizing strategy — frame proposes a size, fixedSize tells SwiftUI to use the view's intrinsic size
tags: mod, frame, fixedSize, sizing
---

## Use frame for Explicit Sizing — fixedSize to Opt Out of Flex

`frame` proposes a width/height to the SwiftUI layout engine — the view *may* be smaller if its content is smaller. `fixedSize` tells SwiftUI to use the view's intrinsic content size and ignore the parent's proposed flex space. These solve different problems: `frame` constrains; `fixedSize` opts out of expansion. Mixing them up causes text to truncate when it should wrap, or buttons to expand when they should hug their label.

**Incorrect (Text wrapped to a tiny frame — truncates instead of wrapping):**

```tsx
import { Host, VStack, Text } from '@expo/ui/swift-ui';
import { frame } from '@expo/ui/swift-ui/modifiers';

<Host matchContents>
  <VStack>
    <Text modifiers={[frame({ width: 100 })]}>
      Your subscription renews on the first of every month.
    </Text>
  </VStack>
</Host>
```

**Correct (frame caps width, Text wraps naturally):**

```tsx
import { Host, VStack, Text } from '@expo/ui/swift-ui';
import { frame } from '@expo/ui/swift-ui/modifiers';

<Host matchContents>
  <VStack>
    <Text modifiers={[frame({ maxWidth: 280 })]}>
      Your subscription renews on the first of every month.
    </Text>
  </VStack>
</Host>
```

**Alternative (button should hug its label, not stretch to fill the HStack):**

```tsx
import { HStack, Button, Spacer } from '@expo/ui/swift-ui';
import { fixedSize } from '@expo/ui/swift-ui/modifiers';

<HStack>
  <Button label="Save" onPress={save} modifiers={[fixedSize()]} />
  <Spacer />
</HStack>
```

Reference: [frame modifier](https://developer.apple.com/documentation/swiftui/view/frame(width:height:alignment:))
