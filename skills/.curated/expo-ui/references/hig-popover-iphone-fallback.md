---
title: Use ConfirmationDialog or BottomSheet on iPhone Instead of Popover
impact: CRITICAL
impactDescription: prevents Popover from rendering as an unanchored sheet on compact widths — breaking HIG popover guidance
tags: hig, popover, iphone, ipad, adaptation
---

## Use ConfirmationDialog or BottomSheet on iPhone Instead of Popover

HIG popover guidance is explicit: popovers are most appropriate on regular-width devices (iPad, Mac). On iPhone (compact width), SwiftUI auto-adapts a `.popover()` to a sheet — the anchor-to-trigger visual relationship HIG recommends is lost, and one-handed iPhone ergonomics suffer because the sheet covers the bottom of the screen. `ConfirmationDialog` adapts cleanly (sheet on iPhone, popover on iPad) for short option lists; `BottomSheet` is the right choice for longer transient content on iPhone.

**Incorrect (Popover used unconditionally — bad fit on iPhone):**

```tsx
import { Host, Popover, Button, Group } from '@expo/ui/swift-ui';

<Host matchContents>
  <Popover isPresented={filterOpen} onIsPresentedChange={setFilterOpen}>
    <Popover.Trigger>
      <Button label="Filter" onPress={() => setFilterOpen(true)} />
    </Popover.Trigger>
    <Popover.Content>
      <Group><FilterOptions /></Group>
    </Popover.Content>
  </Popover>
</Host>
```

**Correct (BottomSheet on iPhone, Popover on iPad via Platform check):**

```tsx
import { Platform } from 'react-native';
import { Host, Popover, BottomSheet, Button, Group } from '@expo/ui/swift-ui';

<Host matchContents>
  <Button label="Filter" onPress={() => setFilterOpen(true)} />
  {Platform.isPad ? (
    <Popover isPresented={filterOpen} onIsPresentedChange={setFilterOpen}>
      <Popover.Content><Group><FilterOptions /></Group></Popover.Content>
    </Popover>
  ) : (
    <BottomSheet isPresented={filterOpen} onIsPresentedChange={setFilterOpen}>
      <Group><FilterOptions /></Group>
    </BottomSheet>
  )}
</Host>
```

**Alternative (ConfirmationDialog auto-adapts for short option lists):**

```tsx
import { Host, ConfirmationDialog, Button } from '@expo/ui/swift-ui';

<Host matchContents>
  <ConfirmationDialog title="Filter by status" isPresented={filterOpen} onIsPresentedChange={setFilterOpen}>
    <ConfirmationDialog.Trigger>
      <Button label="Filter" onPress={() => setFilterOpen(true)} />
    </ConfirmationDialog.Trigger>
    <ConfirmationDialog.Actions>
      <Button label="Active" onPress={() => applyFilter('active')} />
      <Button label="Archived" onPress={() => applyFilter('archived')} />
    </ConfirmationDialog.Actions>
  </ConfirmationDialog>
</Host>
```

Reference: [Popovers | HIG](https://developer.apple.com/design/human-interface-guidelines/popovers)
