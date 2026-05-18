---
title: Apply Visual Modifications via the modifiers Prop, Not React Native style
impact: CRITICAL
impactDescription: prevents silent no-ops — RN style is ignored by every native SwiftUI view in @expo/ui
tags: mod, modifiers, style, native-bridge
---

## Apply Visual Modifications via the modifiers Prop, Not React Native style

SwiftUI views in `@expo/ui/swift-ui` are native views — they do not honour React Native's `style` prop for things like padding, corner radius, background, or shadow. Pass these through the `modifiers` array, where each entry maps to a SwiftUI view modifier on the native side. Setting `style` on a SwiftUI button does nothing visible.

**Incorrect (style prop ignored — button has no padding, no radius):**

```tsx
import { Host, Button } from '@expo/ui/swift-ui';

<Host matchContents>
  <Button
    label="Continue"
    onPress={continueCheckout}
    style={{ padding: 16, borderRadius: 12, backgroundColor: '#0A84FF' }}
  />
</Host>
```

**Correct (modifiers reach the SwiftUI side):**

```tsx
import { Host, Button } from '@expo/ui/swift-ui';
import { padding, cornerRadius, background, foregroundStyle } from '@expo/ui/swift-ui/modifiers';

<Host matchContents>
  <Button
    label="Continue"
    onPress={continueCheckout}
    modifiers={[
      padding({ all: 16 }),
      background('#0A84FF'),
      foregroundStyle('white'),
      cornerRadius(12),
    ]}
  />
</Host>
```

**When NOT to use this pattern:**

- The `style` prop on `Host` itself *is* honoured — that's the React Native side of the bridge. Use it to size the Host, not its SwiftUI children.

Reference: [@expo/ui Host source — only Host accepts a React Native `style` prop; SwiftUI children don't](https://github.com/expo/expo/blob/main/packages/expo-ui/src/swift-ui/Host/index.tsx)
