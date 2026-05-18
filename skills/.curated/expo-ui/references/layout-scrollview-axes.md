---
title: Set axes Explicitly on ScrollView for Horizontal or 2D Scrolling
impact: MEDIUM-HIGH
impactDescription: prevents accidental vertical-only scroll when horizontal or both axes are needed
tags: layout, scrollView, axes, scrolling
---

## Set axes Explicitly on ScrollView for Horizontal or 2D Scrolling

`ScrollView` defaults to `axes='vertical'`. A horizontal carousel of cards rendered without an explicit `axes='horizontal'` simply won't scroll horizontally — the inner HStack will be clipped instead. Set `axes` to match the content's growth axis, or use `axes='both'` for 2D content like maps or large images. Pair with `scrollIndicators` modifier when the default per-axis indicators aren't appropriate.

**Incorrect (default axes='vertical' — horizontal HStack of cards clips off-screen):**

```tsx
import { Host, ScrollView, HStack, Text } from '@expo/ui/swift-ui';
import { padding } from '@expo/ui/swift-ui/modifiers';

<Host matchContents>
  <ScrollView>
    <HStack spacing={12}>
      {recommendations.map((r) => (
        <Text key={r.id} modifiers={[padding({ all: 16 })]}>{r.title}</Text>
      ))}
    </HStack>
  </ScrollView>
</Host>
```

**Correct (axes='horizontal' — cards scroll sideways):**

```tsx
import { Host, ScrollView, HStack, Text } from '@expo/ui/swift-ui';
import { padding } from '@expo/ui/swift-ui/modifiers';

<Host matchContents>
  <ScrollView axes="horizontal" showsIndicators={false}>
    <HStack spacing={12}>
      {recommendations.map((r) => (
        <Text key={r.id} modifiers={[padding({ all: 16 })]}>{r.title}</Text>
      ))}
    </HStack>
  </ScrollView>
</Host>
```

Reference: [@expo/ui ScrollView source](https://github.com/expo/expo/blob/main/packages/expo-ui/src/swift-ui/ScrollView/index.tsx)
