---
title: Pass an Explicit colorScheme to Host When Overriding System Appearance
impact: CRITICAL
impactDescription: prevents SwiftUI tree from reading stale Appearance and forcing the wrong theme
tags: host, colorScheme, theming, dark-mode
---

## Pass an Explicit colorScheme to Host When Overriding System Appearance

SwiftUI reads its color scheme from the hosting environment. Host's `colorScheme` prop seeds the SwiftUI environment with `light` or `dark`; omitting it lets SwiftUI follow the system. Forgetting to set it when the React Native app uses its own theme system (e.g., a theme toggle) leaves SwiftUI content out of sync — buttons render in light mode while the rest of the app is dark.

**Incorrect (theme toggle changes React Native UI but not Host content):**

```tsx
import { useColorScheme } from 'react-native';
import { Host, Button } from '@expo/ui/swift-ui';

export function ActionBar() {
  const scheme = useColorScheme();
  return (
    <Host matchContents>
      <Button label="Save" onPress={save} />
    </Host>
  );
}
```

**Correct (Host receives the same scheme as RN):**

```tsx
import { useColorScheme } from 'react-native';
import { Host, Button } from '@expo/ui/swift-ui';

export function ActionBar() {
  const scheme = useColorScheme();
  return (
    <Host matchContents colorScheme={scheme ?? 'light'}>
      <Button label="Save" onPress={save} />
    </Host>
  );
}
```

**When NOT to use this pattern:**

- If you specifically want SwiftUI to follow the OS appearance regardless of the app's in-app theme override.

Reference: [Host colorScheme prop](https://github.com/expo/expo/blob/main/packages/expo-ui/src/swift-ui/Host/index.tsx)
