---
title: Use the disabled Modifier — Don't Conditionally Render
impact: HIGH
impactDescription: preserves accessibility focus order and prevents layout shift when toggling availability
tags: mod, disabled, accessibility, focus
---

## Use the disabled Modifier — Don't Conditionally Render

Conditional rendering swaps the view out of the tree when the control becomes unavailable. SwiftUI's accessibility focus order then changes (VoiceOver users skip the gap), and any animation tied to the surrounding layout reruns. Applying `disabled(true)` keeps the control in place — it dims visually, blocks interaction, and remains accessible (VoiceOver still reads it, marked as "dimmed").

**Incorrect (conditionally rendered — accessibility focus order shifts when button disappears):**

```tsx
import { Host, Button } from '@expo/ui/swift-ui';

<Host matchContents>
  {form.isValid && (
    <Button label="Submit" onPress={submit} />
  )}
</Host>
```

**Correct (disabled modifier keeps the control mounted):**

```tsx
import { Host, Button } from '@expo/ui/swift-ui';
import { disabled } from '@expo/ui/swift-ui/modifiers';

<Host matchContents>
  <Button label="Submit" onPress={submit} modifiers={[disabled(!form.isValid)]} />
</Host>
```

**When NOT to use this pattern:**

- When the control should be hidden entirely (e.g., a "remove" button on an item that hasn't been added). Conditional render is correct there because the control has no meaning.

Reference: [disabled modifier](https://developer.apple.com/documentation/swiftui/view/disabled(_:))
