---
title: Enable markdownEnabled for Inline Bold, Italic, Links
impact: MEDIUM-HIGH
impactDescription: enables inline markdown formatting — avoids fragile multi-Text concatenation that breaks Dynamic Type wrapping
tags: display, text, markdown, formatting
---

## Enable markdownEnabled for Inline Bold, Italic, Links

`Text.markdownEnabled` opts the SwiftUI Text view into Markdown parsing — `**bold**`, `*italic*`, and `[link](https://...)` render with the right styles inline. The alternative — composing nested `Text` views with individual modifiers — produces a brittle layout that breaks Dynamic Type wrapping, can't render inline links, and forces manual reflow logic. Use Markdown for any sentence-level rich text.

**Incorrect (concatenated Text — bold word breaks wrapping, no inline link):**

```tsx
import { Host, HStack, Text } from '@expo/ui/swift-ui';
import { bold } from '@expo/ui/swift-ui/modifiers';

<Host matchContents>
  <HStack>
    <Text>You have </Text>
    <Text modifiers={[bold()]}>3 unread messages</Text>
    <Text> waiting in your inbox.</Text>
  </HStack>
</Host>
```

**Correct (markdownEnabled — single Text reflows correctly):**

```tsx
import { Host, Text } from '@expo/ui/swift-ui';

<Host matchContents>
  <Text markdownEnabled>
    You have **3 unread messages** waiting in your inbox.
  </Text>
</Host>
```

**Alternative (live timer for "ends in 3:24"):**

```tsx
import { Text } from '@expo/ui/swift-ui';

const endsAt = new Date(Date.now() + 5 * 60 * 1000);

<Text date={endsAt} dateStyle="timer" />
```

Reference: [@expo/ui Text source](https://github.com/expo/expo/blob/main/packages/expo-ui/src/swift-ui/Text/index.tsx)
