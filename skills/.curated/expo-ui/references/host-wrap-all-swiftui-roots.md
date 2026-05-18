---
title: Wrap All SwiftUI Trees in a Host Component
impact: CRITICAL
impactDescription: prevents native view registration failures and missing layout for every SwiftUI descendant
tags: host, boundary, native-bridge, root
---

## Wrap All SwiftUI Trees in a Host Component

`Host` is the only component that mounts a SwiftUI hosting view inside the React Native tree. SwiftUI components from `@expo/ui/swift-ui` are not React Native views — they are native SwiftUI views that need a hosting boundary to receive a size, color scheme, and layout direction from React Native. Rendering a SwiftUI component outside a Host fails silently (no size, no events, no visuals).

**Incorrect (SwiftUI component rendered at React Native root — view never lays out):**

```tsx
import { View } from 'react-native';
import { Button } from '@expo/ui/swift-ui';

export function CheckoutScreen() {
  return (
    <View style={{ flex: 1 }}>
      <Button label="Pay" onPress={submitPayment} />
    </View>
  );
}
```

**Correct (Host bridges into SwiftUI):**

```tsx
import { View } from 'react-native';
import { Host, Button } from '@expo/ui/swift-ui';

export function CheckoutScreen() {
  return (
    <View style={{ flex: 1 }}>
      <Host style={{ height: 56 }}>
        <Button label="Pay" onPress={submitPayment} />
      </Host>
    </View>
  );
}
```

**When NOT to use this pattern:**

- Inside an already-mounted Host. Nesting Host inside Host is redundant — descendants are already in SwiftUI.

Reference: [@expo/ui Host source](https://github.com/expo/expo/blob/main/packages/expo-ui/src/swift-ui/Host/index.tsx)
