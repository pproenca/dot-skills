---
title: Use Link for URL Navigation — Button for In-App Actions
impact: MEDIUM-HIGH
impactDescription: enables system URL handling including SafariViewController fallbacks and universal-link routing
tags: nav, link, button, url
---

## Use Link for URL Navigation — Button for In-App Actions

`Link` renders a SwiftUI link that the system dispatches via the URL handlers — universal links route into the app, web URLs open in SafariViewController, mailto/tel links open the right system app. A `Button` with a custom `Linking.openURL` call bypasses all of that and skips system affordances like long-press preview. Use `Link` whenever the action is "go to this URL"; reserve `Button` for in-app actions.

**Incorrect (Button + Linking.openURL — skips universal-link routing, no long-press preview):**

```tsx
import { Linking } from 'react-native';
import { Host, Button } from '@expo/ui/swift-ui';

<Host matchContents>
  <Button label="Open documentation" onPress={() => Linking.openURL('https://docs.example.com')} />
</Host>
```

**Correct (Link — system handles URL routing and preview):**

```tsx
import { Host, Link } from '@expo/ui/swift-ui';

<Host matchContents>
  <Link label="Open documentation" destination="https://docs.example.com" />
</Host>
```

**Alternative (custom label content for marketing-style links):**

```tsx
import { Link, HStack, Text, Image } from '@expo/ui/swift-ui';
import { foregroundStyle } from '@expo/ui/swift-ui/modifiers';

<Link destination="https://docs.example.com">
  <HStack spacing={6}>
    <Image systemName="book.closed" />
    <Text modifiers={[foregroundStyle('accentColor')]}>Read the guide</Text>
  </HStack>
</Link>
```

Reference: [@expo/ui Link source](https://github.com/expo/expo/blob/main/packages/expo-ui/src/swift-ui/Link/index.tsx)
