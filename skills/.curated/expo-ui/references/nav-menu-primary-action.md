---
title: Set onPrimaryAction on Menu to Disambiguate Tap from Long-Press
impact: MEDIUM-HIGH
impactDescription: enables instant tap for the primary action — without it, every tap opens the menu chooser
tags: nav, menu, primaryAction, gestures
---

## Set onPrimaryAction on Menu to Disambiguate Tap from Long-Press

A SwiftUI `Menu` with `onPrimaryAction` adopts a hybrid affordance: tap runs the primary action immediately; long-press opens the menu chooser. This pattern is iOS-standard for "Send" buttons that also support "Send later", "Schedule send" — fast for the common path, accessible for variants. Without `onPrimaryAction`, every tap opens the menu, forcing an extra interaction for the most common case.

**Incorrect (no primary action — sending an email takes two taps):**

```tsx
import { Host, Menu, Button } from '@expo/ui/swift-ui';

<Host matchContents>
  <Menu label="Send" systemImage="paperplane.fill">
    <Button label="Send now" onPress={sendNow} />
    <Button label="Schedule" onPress={openScheduler} />
    <Button label="Save draft" onPress={saveDraft} />
  </Menu>
</Host>
```

**Correct (primary action — tap sends, long-press for variants):**

```tsx
import { Host, Menu, Button } from '@expo/ui/swift-ui';

<Host matchContents>
  <Menu
    label="Send"
    systemImage="paperplane.fill"
    onPrimaryAction={sendNow}>
    <Button label="Schedule" onPress={openScheduler} />
    <Button label="Save draft" onPress={saveDraft} />
  </Menu>
</Host>
```

**When NOT to use this pattern:**

- When there is no clear "primary" choice — every option in the menu is equally weighted. Plain Menu is correct then.

Reference: [@expo/ui Menu source](https://github.com/expo/expo/blob/main/packages/expo-ui/src/swift-ui/Menu/index.tsx)
