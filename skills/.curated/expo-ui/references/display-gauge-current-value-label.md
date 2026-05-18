---
title: Provide currentValueLabel on Gauge for Accessibility and Context
impact: MEDIUM-HIGH
impactDescription: enables VoiceOver to read the current value and preserves the numeric context for sighted users
tags: display, gauge, accessibility, currentValueLabel
---

## Provide currentValueLabel on Gauge for Accessibility and Context

`Gauge` shows a graphical progress arc but the raw `value` (e.g., `0.73`) is meaningless without a label that interprets it ("73%", "73 of 100 calories", "$730"). Without `currentValueLabel`, VoiceOver announces only the raw fraction and sighted users have to mentally translate the arc position. The label slot is the only way to attach interpretive text that travels with the gauge.

**Incorrect (no currentValueLabel — VoiceOver reads 0.73, sighted users guess):**

```tsx
import { Host, Gauge, Text } from '@expo/ui/swift-ui';

<Host matchContents>
  <Gauge value={0.73}>
    <Text>Calories</Text>
  </Gauge>
</Host>
```

**Correct (currentValueLabel — both VoiceOver and sighted users get context):**

```tsx
import { Host, Gauge, Text } from '@expo/ui/swift-ui';

<Host matchContents>
  <Gauge
    value={0.73}
    currentValueLabel={<Text>1,460 / 2,000 kcal</Text>}>
    <Text>Calories</Text>
  </Gauge>
</Host>
```

**Alternative (closed range gauge with min/max value labels):**

```tsx
<Gauge
  value={185}
  min={120}
  max={220}
  currentValueLabel={<Text>185 bpm</Text>}
  minimumValueLabel={<Text>120</Text>}
  maximumValueLabel={<Text>220</Text>}>
  <Text>Heart rate</Text>
</Gauge>
```

Reference: [@expo/ui Gauge source](https://github.com/expo/expo/blob/main/packages/expo-ui/src/swift-ui/Gauge/index.tsx)
