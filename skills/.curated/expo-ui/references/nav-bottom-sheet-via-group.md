---
title: Wrap BottomSheet Content in Group to Attach Presentation Modifiers
impact: HIGH
impactDescription: enables detents, drag indicator, and background interaction modifiers — bare content can't attach them
tags: nav, bottomSheet, group, presentation
---

## Wrap BottomSheet Content in Group to Attach Presentation Modifiers

`BottomSheet`'s children must be a single SwiftUI view that accepts the `modifiers` array — `Group` is the standard "transparent container" that carries presentation modifiers (`presentationDetents`, `presentationDragIndicator`, `interactiveDismissDisabled`) to the sheet's content surface. Rendering bare children leaves the sheet with no way to attach those modifiers — it falls back to defaults (large detent only, no drag indicator).

**Incorrect (bare children — presentation modifiers have nowhere to attach):**

```tsx
import { Host, BottomSheet, VStack, Text, Button } from '@expo/ui/swift-ui';

<Host matchContents>
  <BottomSheet isPresented={open} onIsPresentedChange={setOpen}>
    <VStack>
      <Text>Are you sure?</Text>
      <Button label="Confirm" onPress={confirm} />
    </VStack>
  </BottomSheet>
</Host>
```

**Correct (Group carries the presentation modifiers):**

```tsx
import { Host, BottomSheet, Group, VStack, Text, Button } from '@expo/ui/swift-ui';
import { presentationDetents, presentationDragIndicator } from '@expo/ui/swift-ui/modifiers';

<Host matchContents>
  <BottomSheet isPresented={open} onIsPresentedChange={setOpen}>
    <Group modifiers={[presentationDetents(['medium']), presentationDragIndicator('visible')]}>
      <VStack>
        <Text>Are you sure?</Text>
        <Button label="Confirm" onPress={confirm} />
      </VStack>
    </Group>
  </BottomSheet>
</Host>
```

Reference: [BottomSheet JSDoc — uses Group for presentation modifiers](https://github.com/expo/expo/blob/main/packages/expo-ui/src/swift-ui/BottomSheet/index.tsx)
