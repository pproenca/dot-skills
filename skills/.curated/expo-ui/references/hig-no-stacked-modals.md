---
title: Avoid Presenting a Sheet from Inside Another Sheet
impact: CRITICAL
impactDescription: prevents users from facing multiple dismissal layers and disorientation
tags: hig, modality, sheet, presentation
---

## Avoid Presenting a Sheet from Inside Another Sheet

Apple's HIG on modality says: minimise modal layers. Stacking a `BottomSheet` over a `BottomSheet`, or an `Alert` over a `ConfirmationDialog`, forces the user to dismiss multiple layers to return to the underlying screen — and on iOS 26 the floating Liquid Glass appearance only renders correctly for the outermost sheet. Resolve the first sheet's task before presenting the next, or redesign the flow as a navigation push.

**Incorrect (sheet-from-sheet — user must dismiss twice):**

```tsx
import { Host, BottomSheet, Group, Button } from '@expo/ui/swift-ui';

<Host matchContents>
  <BottomSheet isPresented={editorOpen} onIsPresentedChange={setEditorOpen}>
    <Group>
      <Button label="Open advanced" onPress={() => setAdvancedOpen(true)} />
      <BottomSheet isPresented={advancedOpen} onIsPresentedChange={setAdvancedOpen}>
        <Group><AdvancedSettings /></Group>
      </BottomSheet>
    </Group>
  </BottomSheet>
</Host>
```

**Correct (push the advanced view onto the first sheet's navigation stack):**

```tsx
import { Host, BottomSheet, Group, Button } from '@expo/ui/swift-ui';

<Host matchContents>
  <BottomSheet isPresented={editorOpen} onIsPresentedChange={setEditorOpen}>
    <Group>
      {advancedOpen
        ? <AdvancedSettings onBack={() => setAdvancedOpen(false)} />
        : <Button label="Open advanced" onPress={() => setAdvancedOpen(true)} />}
    </Group>
  </BottomSheet>
</Host>
```

**When NOT to use this pattern:**

- A `ConfirmationDialog` presented from within a sheet to confirm a destructive action *is* permitted by HIG, because it's a short transient confirmation, not a stacked task.

Reference: [Modality | HIG](https://developer.apple.com/design/human-interface-guidelines/modality)
