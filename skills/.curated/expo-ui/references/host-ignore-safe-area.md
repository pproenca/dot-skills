---
title: Use ignoreSafeArea Only for Full-Bleed Surfaces
impact: CRITICAL
impactDescription: prevents controls from sliding under the home indicator or notch
tags: host, safeArea, layout
---

## Use ignoreSafeArea Only for Full-Bleed Surfaces

`ignoreSafeArea` on Host tells SwiftUI to extend its content under the safe area insets. Setting it indiscriminately pushes interactive controls (buttons, text fields) under the Dynamic Island or home indicator where the user cannot reach them. Reserve it for backgrounds and decorative content that should bleed edge-to-edge.

**Incorrect (action sheet content goes under the home indicator):**

```tsx
import { Host, BottomSheet, Group, Button } from '@expo/ui/swift-ui';

<Host ignoreSafeArea="all" matchContents>
  <BottomSheet isPresented onIsPresentedChange={setOpen}>
    <Group>
      <Button label="Delete account" onPress={deleteAccount} />
    </Group>
  </BottomSheet>
</Host>
```

**Correct (only ignore safe area on the background layer):**

```tsx
import { Host, BottomSheet, Group, Button } from '@expo/ui/swift-ui';

<Host matchContents>
  <BottomSheet isPresented onIsPresentedChange={setOpen}>
    <Group>
      <Button label="Delete account" onPress={deleteAccount} />
    </Group>
  </BottomSheet>
</Host>
```

**Alternative (ignore only the keyboard inset for a chat composer):**

```tsx
<Host ignoreSafeArea="keyboard" matchContents>
  <ChatComposer />
</Host>
```

**Warning (mount-only setting):**

Like `matchContents`, `ignoreSafeArea` is read once on mount. Changing it later has no effect.

Reference: [Host ignoreSafeArea](https://github.com/expo/expo/blob/main/packages/expo-ui/src/swift-ui/Host/index.tsx)
