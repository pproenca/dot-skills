---
title: Use matchContents to Size Host to Its SwiftUI Content
impact: CRITICAL
impactDescription: prevents zero-height hosts and layout glitches when SwiftUI content is intrinsically sized
tags: host, sizing, matchContents, layout
---

## Use matchContents to Size Host to Its SwiftUI Content

By default, Host takes whatever size React Native gives it via `style`. SwiftUI components like `Button`, `Text`, and `Image` are intrinsically sized — without an explicit React Native frame, Host collapses to 0×0 and content disappears. `matchContents` lets the SwiftUI layout drive the Host's measured size back into React Native.

**Incorrect (Host has no size — Button renders into 0×0):**

```tsx
import { Host, Button } from '@expo/ui/swift-ui';

<Host>
  <Button label="Subscribe" onPress={handleSubscribe} />
</Host>
```

**Correct (Host adopts the SwiftUI content size):**

```tsx
import { Host, Button } from '@expo/ui/swift-ui';

<Host matchContents>
  <Button label="Subscribe" onPress={handleSubscribe} />
</Host>
```

**Alternative (axis-specific matching for horizontal-only):**

```tsx
<Host matchContents={{ horizontal: true }} style={{ height: 56 }}>
  <Button label="Subscribe" onPress={handleSubscribe} />
</Host>
```

**Warning (matchContents is mount-only):**

The `matchContents` prop is read once on mount. Changing its value later does nothing. Decide up front whether the Host should self-size or be sized by React Native.

Reference: [Host props](https://github.com/expo/expo/blob/main/packages/expo-ui/src/swift-ui/Host/index.tsx)
