---
title: Use Grid for Column-Aligned Content — Stacks Don't Align Across Rows
impact: MEDIUM-HIGH
impactDescription: enables cells in successive rows to line up — VStack of HStacks lets each row size its columns independently
tags: layout, grid, stacks, alignment
---

## Use Grid for Column-Aligned Content — Stacks Don't Align Across Rows

A VStack of HStacks sizes each HStack independently — column widths drift, labels misalign, and the result reads as a list rather than a table. `Grid` (with `Grid.Row` children) propagates column widths across rows so cells in the same column have the same width. Use Grid whenever rows share a column structure (labelled forms, key/value tables, two-column tags).

**Incorrect (VStack of HStacks — second column drifts):**

```tsx
import { Host, VStack, HStack, Text } from '@expo/ui/swift-ui';

<Host matchContents>
  <VStack alignment="leading" spacing={4}>
    <HStack spacing={12}>
      <Text>Plan</Text>
      <Text>Pro Monthly</Text>
    </HStack>
    <HStack spacing={12}>
      <Text>Renews</Text>
      <Text>1 June 2026</Text>
    </HStack>
  </VStack>
</Host>
```

**Correct (Grid — both columns line up across rows):**

```tsx
import { Host, Grid, Text } from '@expo/ui/swift-ui';

<Host matchContents>
  <Grid alignment="leading" horizontalSpacing={16} verticalSpacing={4}>
    <Grid.Row>
      <Text>Plan</Text>
      <Text>Pro Monthly</Text>
    </Grid.Row>
    <Grid.Row>
      <Text>Renews</Text>
      <Text>1 June 2026</Text>
    </Grid.Row>
  </Grid>
</Host>
```

**When NOT to use this pattern:**

- Free-flowing content where row sizes are intentionally independent (a feed of cards). Stack composition fits there.

Reference: [Grid | SwiftUI](https://developer.apple.com/documentation/swiftui/grid)
