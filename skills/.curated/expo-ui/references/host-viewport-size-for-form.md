---
title: Use useViewportSizeMeasurement for Form and Fill-Available Content
impact: CRITICAL
impactDescription: enables Form and List to expand to the available viewport instead of collapsing
tags: host, form, viewport, sizing
---

## Use useViewportSizeMeasurement for Form and Fill-Available Content

SwiftUI's `Form` and `List` propose to fill all available space — they expect the parent to offer a concrete size. Inside a Host configured with `matchContents`, that available size is unknown, so the form collapses. `useViewportSizeMeasurement` tells the Host to propose the viewport size to SwiftUI layout before measuring back.

**Incorrect (Form collapses inside Host with matchContents):**

```tsx
import { Host, Form, Section, TextField } from '@expo/ui/swift-ui';

<Host matchContents style={{ flex: 1 }}>
  <Form>
    <Section title="Profile">
      <TextField placeholder="Display name" />
    </Section>
  </Form>
</Host>
```

**Correct (Host proposes viewport size to Form):**

```tsx
import { Host, Form, Section, TextField } from '@expo/ui/swift-ui';

<Host useViewportSizeMeasurement style={{ flex: 1 }}>
  <Form>
    <Section title="Profile">
      <TextField placeholder="Display name" />
    </Section>
  </Form>
</Host>
```

**When NOT to use this pattern:**

- For intrinsically sized content (single Button, Text, Image). Use `matchContents` instead — the viewport-size mode would inflate the Host to fill the screen.

Reference: [Host useViewportSizeMeasurement](https://github.com/expo/expo/blob/main/packages/expo-ui/src/swift-ui/Host/index.tsx)
