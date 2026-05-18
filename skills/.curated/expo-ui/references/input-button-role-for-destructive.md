---
title: Use Button role='destructive' for Delete-Style Actions
impact: HIGH
impactDescription: enables system-red styling, VoiceOver announcement, and HIG-correct semantic — prevents accidental confirms
tags: input, button, role, destructive, accessibility
---

## Use Button role='destructive' for Delete-Style Actions

The `role` prop maps to SwiftUI's `ButtonRole`. `destructive` renders the button in the system's destructive color (red on iOS), is announced as destructive by VoiceOver, and is positioned by the system at the bottom of confirmation dialogs and context menus. Faking the look with a tint modifier gives the colour but loses the semantics — and on iPad popovers the system arranges destructive actions differently.

**Incorrect (tint-only — wrong VoiceOver semantic, wrong system placement):**

```tsx
import { Host, Button } from '@expo/ui/swift-ui';
import { tint } from '@expo/ui/swift-ui/modifiers';

<Host matchContents>
  <Button label="Delete listing" onPress={deleteListing} modifiers={[tint('#FF3B30')]} />
</Host>
```

**Correct (role drives colour + semantics):**

```tsx
import { Host, Button } from '@expo/ui/swift-ui';

<Host matchContents>
  <Button role="destructive" label="Delete listing" onPress={deleteListing} />
</Host>
```

**Alternative (cancel role for dismissal buttons in dialogs):**

```tsx
<Button role="cancel" label="Keep listing" onPress={closeDialog} />
```

Reference: [@expo/ui Button source](https://github.com/expo/expo/blob/main/packages/expo-ui/src/swift-ui/Button/index.tsx)
