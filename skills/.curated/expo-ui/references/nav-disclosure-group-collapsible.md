---
title: Use DisclosureGroup for Collapsible Detail Inside Forms
impact: MEDIUM-HIGH
impactDescription: enables HIG-correct expand/collapse chevron — Section's isExpanded only works inside sidebar lists
tags: nav, disclosureGroup, collapsible, form
---

## Use DisclosureGroup for Collapsible Detail Inside Forms

`DisclosureGroup` is SwiftUI's expand/collapse primitive for detail rows: a label, a chevron, and a body of children that animates open. It works in any container — Form, List, VStack — unlike `Section`'s `isExpanded` prop, which only applies inside a list with sidebar style. For optional advanced fields inside a settings form, DisclosureGroup is the right choice.

**Incorrect (Section.isExpanded inside a regular Form — chevron doesn't appear):**

```tsx
import { Host, Form, Section, Toggle } from '@expo/ui/swift-ui';

<Host useViewportSizeMeasurement style={{ flex: 1 }}>
  <Form>
    <Section
      title="Advanced"
      isExpanded={advancedOpen}
      onIsExpandedChange={setAdvancedOpen}>
      <Toggle label="Telemetry" isOn={telemetry} onIsOnChange={setTelemetry} />
    </Section>
  </Form>
</Host>
```

**Correct (DisclosureGroup — works inside any Form):**

```tsx
import { Host, Form, Section, DisclosureGroup, Toggle } from '@expo/ui/swift-ui';

<Host useViewportSizeMeasurement style={{ flex: 1 }}>
  <Form>
    <Section title="Privacy">
      <DisclosureGroup
        label="Advanced"
        isExpanded={advancedOpen}
        onIsExpandedChange={setAdvancedOpen}>
        <Toggle label="Telemetry" isOn={telemetry} onIsOnChange={setTelemetry} />
      </DisclosureGroup>
    </Section>
  </Form>
</Host>
```

Reference: [@expo/ui DisclosureGroup source](https://github.com/expo/expo/blob/main/packages/expo-ui/src/swift-ui/DisclosureGroup/index.tsx)
