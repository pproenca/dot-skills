---
title: Use LazyVStack or LazyHStack for Long Lists Inside ScrollView
impact: HIGH
impactDescription: defers off-screen row layout — eager VStack frames every child at mount, 10-100× initial-layout cost on 500-row lists
tags: layout, lazyVStack, lazyHStack, scrollView, performance
---

## Use LazyVStack or LazyHStack for Long Lists Inside ScrollView

`VStack` and `HStack` lay out all their children eagerly when mounted, regardless of whether they are visible. Inside a `ScrollView`, that means a 500-row list pays the full layout cost up front. `LazyVStack`/`LazyHStack` defer the layout of each child until it enters the viewport — initial scroll feels instant even for very long lists. Prefer `List` when you also need section headers, separators, or selection; reserve the lazy stacks for ScrollView-based custom layouts.

**Incorrect (eager VStack inside ScrollView — frames every transaction at mount):**

```tsx
import { Host, ScrollView, VStack, Text } from '@expo/ui/swift-ui';

<Host useViewportSizeMeasurement style={{ flex: 1 }}>
  <ScrollView>
    <VStack alignment="leading" spacing={8}>
      {transactions.map((t) => (
        <Text key={t.id}>{t.merchant} — {t.amount}</Text>
      ))}
    </VStack>
  </ScrollView>
</Host>
```

**Correct (LazyVStack — only on-screen rows are laid out):**

```tsx
import { Host, ScrollView, LazyVStack, Text } from '@expo/ui/swift-ui';

<Host useViewportSizeMeasurement style={{ flex: 1 }}>
  <ScrollView>
    <LazyVStack alignment="leading" spacing={8}>
      {transactions.map((t) => (
        <Text key={t.id}>{t.merchant} — {t.amount}</Text>
      ))}
    </LazyVStack>
  </ScrollView>
</Host>
```

**When NOT to use this pattern:**

- Very short lists (< 20 rows) where the lazy machinery costs more than the savings.
- Heterogeneous list shapes (sections, headers, selection). Use `List` instead.

Reference: [@expo/ui LazyVStack source](https://github.com/expo/expo/blob/main/packages/expo-ui/src/swift-ui/LazyVStack/index.tsx)
