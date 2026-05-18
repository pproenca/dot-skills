---
title: Use Form for Settings-Style Screens — Not VStack Inside ScrollView
impact: HIGH
impactDescription: enables inset-grouped chrome, automatic separators, and HIG-correct settings styling
tags: layout, form, settings, ios-design
---

## Use Form for Settings-Style Screens — Not VStack Inside ScrollView

`Form` is SwiftUI's container for data entry and settings — it automatically applies inset-grouped backgrounds, separates rows, lays out labels and inputs to the platform's standard, and supports nested `Section` blocks with headers and footers. Reconstructing this look with VStack/ScrollView and custom dividers produces a brittle approximation that drifts as iOS updates. Reach for `Form` whenever the screen is a list of settings, profile fields, or grouped controls.

**Incorrect (VStack-based settings — divergent visuals, no automatic grouping):**

```tsx
import { Host, ScrollView, VStack, Divider, Text, Toggle, TextField } from '@expo/ui/swift-ui';

<Host useViewportSizeMeasurement style={{ flex: 1 }}>
  <ScrollView>
    <VStack alignment="leading" spacing={16}>
      <Text>Notifications</Text>
      <Toggle label="Push" isOn={push} onIsOnChange={setPush} />
      <Divider />
      <Toggle label="Email" isOn={email} onIsOnChange={setEmail} />
    </VStack>
  </ScrollView>
</Host>
```

**Correct (Form with Section — adopts iOS grouped chrome):**

```tsx
import { Host, Form, Section, Toggle } from '@expo/ui/swift-ui';

<Host useViewportSizeMeasurement style={{ flex: 1 }}>
  <Form>
    <Section title="Notifications">
      <Toggle label="Push" isOn={push} onIsOnChange={setPush} />
      <Toggle label="Email" isOn={email} onIsOnChange={setEmail} />
    </Section>
  </Form>
</Host>
```

**When NOT to use this pattern:**

- Free-form content layouts (a marketing screen, a custom dashboard). Use ScrollView + VStack.

Reference: [Form | SwiftUI](https://developer.apple.com/documentation/swiftui/form)
