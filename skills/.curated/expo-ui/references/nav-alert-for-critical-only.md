---
title: Use Alert Only for App-Blocking Critical Information
impact: HIGH
impactDescription: prevents alert fatigue — reserves the highest-modality affordance for critical events
tags: nav, alert, modality, hig
---

## Use Alert Only for App-Blocking Critical Information

Apple's HIG positions `Alert` as the highest-modality presentation: it blocks all other interaction until dismissed. Reach for it only when the information is critical and the user must acknowledge it before continuing — auth errors, irreversible failures, system-level prompts. For everything else (filters, options, confirmations, supplementary information) use the lighter presentation: `ConfirmationDialog`, `BottomSheet`, `Popover`, `Menu`.

**Incorrect (Alert for a non-critical filter choice — over-modal):**

```tsx
import { Host, Alert, Button } from '@expo/ui/swift-ui';

<Host matchContents>
  <Alert title="Choose sort order" isPresented={open} onIsPresentedChange={setOpen}>
    <Alert.Trigger>
      <Button label="Sort" onPress={() => setOpen(true)} />
    </Alert.Trigger>
    <Alert.Actions>
      <Button label="Newest" onPress={() => applySort('newest')} />
      <Button label="Oldest" onPress={() => applySort('oldest')} />
    </Alert.Actions>
  </Alert>
</Host>
```

**Correct (ConfirmationDialog — lighter modality for option choices):**

```tsx
import { Host, ConfirmationDialog, Button } from '@expo/ui/swift-ui';

<Host matchContents>
  <ConfirmationDialog title="Choose sort order" isPresented={open} onIsPresentedChange={setOpen}>
    <ConfirmationDialog.Trigger>
      <Button label="Sort" onPress={() => setOpen(true)} />
    </ConfirmationDialog.Trigger>
    <ConfirmationDialog.Actions>
      <Button label="Newest" onPress={() => applySort('newest')} />
      <Button label="Oldest" onPress={() => applySort('oldest')} />
    </ConfirmationDialog.Actions>
  </ConfirmationDialog>
</Host>
```

**When NOT to use this pattern:**

- Genuinely blocking conditions: payment failure, auth expired, data-loss confirmation. Alert is the correct affordance there.

Reference: [Modality | HIG](https://developer.apple.com/design/human-interface-guidelines/modality)
