---
title: Include a Partial Detent to Enable the Liquid Glass Sheet Appearance
impact: CRITICAL
impactDescription: enables the floating Liquid Glass sheet — `.large`-only sheets fall back to edge-anchored opaque chrome on iOS 26
tags: hig, sheet, detents, liquid-glass, ios-26
---

## Include a Partial Detent to Enable the Liquid Glass Sheet Appearance

iOS 26 only renders the floating, glass-edged sheet appearance when the sheet supports at least one partial-height detent (`.medium`, a `fraction`, or a fixed `height`). A `.large`-only configuration anchors the sheet to the screen edges with an opaque background — visually the pre-iOS-26 fallback. Always include a partial detent unless the screen genuinely requires full immersion.

**Incorrect (large-only detent — sheet loses Liquid Glass appearance):**

```tsx
import { Host, BottomSheet, Group, Form } from '@expo/ui/swift-ui';
import { presentationDetents } from '@expo/ui/swift-ui/modifiers';

<Host useViewportSizeMeasurement style={{ flex: 1 }}>
  <BottomSheet isPresented={open} onIsPresentedChange={setOpen}>
    <Group modifiers={[presentationDetents(['large'])]}>
      <Form><AccountSettings /></Form>
    </Group>
  </BottomSheet>
</Host>
```

**Correct (medium + large — sheet floats with Liquid Glass):**

```tsx
import { Host, BottomSheet, Group, Form } from '@expo/ui/swift-ui';
import { presentationDetents } from '@expo/ui/swift-ui/modifiers';

<Host useViewportSizeMeasurement style={{ flex: 1 }}>
  <BottomSheet isPresented={open} onIsPresentedChange={setOpen}>
    <Group modifiers={[presentationDetents(['medium', 'large'])]}>
      <Form><AccountSettings /></Form>
    </Group>
  </BottomSheet>
</Host>
```

**Alternative (content-sized sheet for short tasks):**

```tsx
<BottomSheet isPresented={open} onIsPresentedChange={setOpen} fitToContents>
  <Group><QuickAction /></Group>
</BottomSheet>
```

Reference: [presentationDetents | SwiftUI](https://developer.apple.com/documentation/swiftui/view/presentationdetents(_:))
