---
title: Use Section.header and Section.footer Slots for Grouped Context
impact: MEDIUM-HIGH
impactDescription: enables rich contextual headers and explanatory footers without breaking out of the Form/List chrome
tags: layout, section, header, footer, form
---

## Use Section.header and Section.footer Slots for Grouped Context

`Section` accepts either a `title` string (rendered as the default header style) or a custom `header` slot — and likewise a `footer` slot. Use the slot form when the header needs an icon, multiple weights of text, or live content; use the footer slot for the explanatory disclaimer text iOS Settings uses (`"Email notifications are sent to admin@therocketgrowth.com"`). Sections without these affordances feel less native.

**Incorrect (footer-as-Text-row — disrupts grouped chrome, no italic muted styling):**

```tsx
import { Host, Form, Section, Toggle, Text } from '@expo/ui/swift-ui';

<Host useViewportSizeMeasurement style={{ flex: 1 }}>
  <Form>
    <Section title="Email digest">
      <Toggle label="Weekly summary" isOn={weekly} onIsOnChange={setWeekly} />
      <Text>Sent every Monday at 8 AM in your local timezone.</Text>
    </Section>
  </Form>
</Host>
```

**Correct (footer slot — caption text muted and below the section):**

```tsx
import { Host, Form, Section, Toggle, Text } from '@expo/ui/swift-ui';

<Host useViewportSizeMeasurement style={{ flex: 1 }}>
  <Form>
    <Section
      title="Email digest"
      footer={<Text>Sent every Monday at 8 AM in your local timezone.</Text>}>
      <Toggle label="Weekly summary" isOn={weekly} onIsOnChange={setWeekly} />
    </Section>
  </Form>
</Host>
```

**Alternative (custom header with live state for sidebar collapsible sections, iOS 17+):**

```tsx
import { Section, HStack, Text, Image } from '@expo/ui/swift-ui';

<Section
  header={
    <HStack alignment="firstTextBaseline" spacing={6}>
      <Image systemName="bell.badge" />
      <Text>Pending invites</Text>
    </HStack>
  }
  isExpanded={pendingOpen}
  onIsExpandedChange={setPendingOpen}>
  <InviteRow />
</Section>
```

Reference: [@expo/ui Section source](https://github.com/expo/expo/blob/main/packages/expo-ui/src/swift-ui/Section/index.tsx)
