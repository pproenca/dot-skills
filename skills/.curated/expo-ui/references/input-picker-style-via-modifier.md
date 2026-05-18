---
title: Set Picker Appearance via pickerStyle Modifier, Not a Prop
impact: HIGH
impactDescription: enables the four Picker appearances (wheel, segmented, menu, inline) — Picker takes no style prop
tags: input, picker, pickerStyle, modifier
---

## Set Picker Appearance via pickerStyle Modifier, Not a Prop

`Picker` does not have a `style` or `variant` prop — its appearance comes from the `pickerStyle` modifier. Without it, the picker renders in its `automatic` default which iOS often chooses to be wheel-style inside Forms but menu-style elsewhere. Specifying the modifier locks in the appearance you want and keeps the picker visually consistent across Form vs free-floating placements.

**Incorrect (no pickerStyle — default appearance varies by container):**

```tsx
import { Host, Picker, Text } from '@expo/ui/swift-ui';
import { tag } from '@expo/ui/swift-ui/modifiers';

<Host matchContents>
  <Picker label="Plan" selection={plan} onSelectionChange={setPlan}>
    <Text modifiers={[tag('basic')]}>Basic</Text>
    <Text modifiers={[tag('pro')]}>Pro</Text>
    <Text modifiers={[tag('enterprise')]}>Enterprise</Text>
  </Picker>
</Host>
```

**Correct (segmented Picker — explicit appearance):**

```tsx
import { Host, Picker, Text } from '@expo/ui/swift-ui';
import { pickerStyle, tag } from '@expo/ui/swift-ui/modifiers';

<Host matchContents>
  <Picker
    label="Plan"
    selection={plan}
    onSelectionChange={setPlan}
    modifiers={[pickerStyle('segmented')]}>
    <Text modifiers={[tag('basic')]}>Basic</Text>
    <Text modifiers={[tag('pro')]}>Pro</Text>
    <Text modifiers={[tag('enterprise')]}>Enterprise</Text>
  </Picker>
</Host>
```

**Alternative (menu-style for long option lists):**

```tsx
<Picker
  label="Country"
  selection={country}
  onSelectionChange={setCountry}
  modifiers={[pickerStyle('menu')]}>
  {countries.map((c) => <Text key={c.code} modifiers={[tag(c.code)]}>{c.name}</Text>)}
</Picker>
```

Reference: [@expo/ui Picker source](https://github.com/expo/expo/blob/main/packages/expo-ui/src/swift-ui/Picker/index.tsx)
