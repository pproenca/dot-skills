---
title: Apply Presentation Modifiers to Sheet Content, Not the Trigger
impact: CRITICAL
impactDescription: prevents the modifier from attaching to the wrong view — modifiers on the trigger do nothing
tags: mod, presentation, sheet, bottomSheet
---

## Apply Presentation Modifiers to Sheet Content, Not the Trigger

`presentationDetents`, `presentationDragIndicator`, `presentationBackgroundInteraction`, and `interactiveDismissDisabled` configure the presented view, not the view that triggered presentation. They must be applied to the sheet's content (in expo-ui, the `Group` inside `BottomSheet`'s children), not to the button that opens the sheet. Misapplied, they silently no-op.

**Incorrect (presentation modifiers on the trigger button — no effect):**

```tsx
import { Host, BottomSheet, Group, Button } from '@expo/ui/swift-ui';
import { presentationDetents, presentationDragIndicator } from '@expo/ui/swift-ui/modifiers';

<Host matchContents>
  <Button
    label="Edit"
    onPress={() => setOpen(true)}
    modifiers={[presentationDetents(['medium']), presentationDragIndicator('visible')]}
  />
  <BottomSheet isPresented={open} onIsPresentedChange={setOpen}>
    <Group>
      <EditorContent />
    </Group>
  </BottomSheet>
</Host>
```

**Correct (modifiers attached to the sheet's content Group):**

```tsx
import { Host, BottomSheet, Group, Button } from '@expo/ui/swift-ui';
import { presentationDetents, presentationDragIndicator } from '@expo/ui/swift-ui/modifiers';

<Host matchContents>
  <Button label="Edit" onPress={() => setOpen(true)} />
  <BottomSheet isPresented={open} onIsPresentedChange={setOpen}>
    <Group modifiers={[presentationDetents(['medium', 'large']), presentationDragIndicator('visible')]}>
      <EditorContent />
    </Group>
  </BottomSheet>
</Host>
```

Reference: [BottomSheet expects Group with presentation modifiers](https://github.com/expo/expo/blob/main/packages/expo-ui/src/swift-ui/BottomSheet/index.tsx)
