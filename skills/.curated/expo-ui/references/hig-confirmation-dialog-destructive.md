---
title: Use ConfirmationDialog with role='destructive' for Destructive Confirmations
impact: CRITICAL
impactDescription: enables system-red destructive styling and proper VoiceOver semantics — prevents accidental data loss
tags: hig, confirmation, destructive, accessibility
---

## Use ConfirmationDialog with role='destructive' for Destructive Confirmations

HIG's action-sheet guidance: confirm destructive, irreversible actions with a confirmation dialog whose primary action carries the `.destructive` role. The role drives both the system red colour *and* VoiceOver semantics that announce the action as destructive — a plain `Button` styled red gives the colour but not the semantics, and a plain `Alert` doesn't adapt to a popover on iPad. `ConfirmationDialog` handles all three concerns.

**Incorrect (Alert with red tint — wrong semantics, no iPad popover adaptation):**

```tsx
import { Host, Alert, Button } from '@expo/ui/swift-ui';
import { tint } from '@expo/ui/swift-ui/modifiers';

<Host matchContents>
  <Alert title="Delete account?" isPresented={confirmOpen} onIsPresentedChange={setConfirmOpen}>
    <Alert.Trigger>
      <Button label="Delete" onPress={() => setConfirmOpen(true)} />
    </Alert.Trigger>
    <Alert.Actions>
      <Button label="Delete forever" onPress={deleteAccount} modifiers={[tint('#FF3B30')]} />
      <Button label="Cancel" onPress={() => setConfirmOpen(false)} />
    </Alert.Actions>
  </Alert>
</Host>
```

**Correct (ConfirmationDialog + destructive role):**

```tsx
import { Host, ConfirmationDialog, Button } from '@expo/ui/swift-ui';

<Host matchContents>
  <ConfirmationDialog title="Delete account?" isPresented={confirmOpen} onIsPresentedChange={setConfirmOpen}>
    <ConfirmationDialog.Trigger>
      <Button label="Delete" onPress={() => setConfirmOpen(true)} />
    </ConfirmationDialog.Trigger>
    <ConfirmationDialog.Message>
      This permanently removes your data. It cannot be undone.
    </ConfirmationDialog.Message>
    <ConfirmationDialog.Actions>
      <Button role="destructive" label="Delete forever" onPress={deleteAccount} />
      <Button role="cancel" label="Cancel" onPress={() => setConfirmOpen(false)} />
    </ConfirmationDialog.Actions>
  </ConfirmationDialog>
</Host>
```

**When NOT to use this pattern:**

- For non-destructive confirmations (e.g., "Save changes?"). A plain `Alert` is appropriate.

Reference: [Action sheets | HIG](https://developer.apple.com/design/human-interface-guidelines/action-sheets)
