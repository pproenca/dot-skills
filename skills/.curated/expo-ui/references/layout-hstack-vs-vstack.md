---
title: Pick Stack Direction by Content Flow — HStack for Rows, VStack for Columns
impact: HIGH
impactDescription: prevents content from wrapping or overflowing the wrong axis
tags: layout, hstack, vstack, stacks
---

## Pick Stack Direction by Content Flow — HStack for Rows, VStack for Columns

`HStack` arranges children horizontally with a single-row constraint; `VStack` does the opposite. Children inherit the cross-axis size from the stack — an `HStack` of long text gives each text view a sliver of horizontal space, while a `VStack` of the same gives each the full row width. Choose the direction that matches the *natural* growth axis of the content.

**Incorrect (HStack for a list of subscription benefits — text gets cut off):**

```tsx
import { Host, HStack, Text } from '@expo/ui/swift-ui';

<Host matchContents>
  <HStack spacing={12}>
    <Text>Unlimited storage</Text>
    <Text>Priority support</Text>
    <Text>Early access to new features</Text>
  </HStack>
</Host>
```

**Correct (VStack matches the column-list nature of the content):**

```tsx
import { Host, VStack, Text } from '@expo/ui/swift-ui';

<Host matchContents>
  <VStack alignment="leading" spacing={12}>
    <Text>Unlimited storage</Text>
    <Text>Priority support</Text>
    <Text>Early access to new features</Text>
  </VStack>
</Host>
```

**Alternative (HStack with explicit baseline alignment for icon + label rows):**

```tsx
import { HStack, Image, Text } from '@expo/ui/swift-ui';

<HStack alignment="firstTextBaseline" spacing={8}>
  <Image systemName="checkmark.circle.fill" />
  <Text>Verified</Text>
</HStack>
```

Reference: [@expo/ui HStack source](https://github.com/expo/expo/blob/main/packages/expo-ui/src/swift-ui/HStack/index.tsx)
