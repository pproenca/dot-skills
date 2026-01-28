---
title: Use FlashList Instead of FlatList for Large Lists
impact: CRITICAL
impactDescription: 54% FPS improvement, 82% CPU reduction
tags: list, flashlist, flatlist, virtualization, performance
---

## Use FlashList Instead of FlatList for Large Lists

FlashList from Shopify recycles components instead of creating/destroying them, dramatically improving scroll performance.

**Incorrect (FlatList with poor performance):**

```tsx
import { FlatList } from 'react-native'

function ProductList({ products }) {
  return (
    <FlatList
      data={products}
      renderItem={({ item }) => <ProductCard product={item} />}
      keyExtractor={item => item.id}
    />
  )
}
// Average 36.9 FPS, high CPU usage on scroll
```

**Correct (FlashList with recycling):**

```tsx
import { FlashList } from '@shopify/flash-list'

function ProductList({ products }) {
  return (
    <FlashList
      data={products}
      renderItem={({ item }) => <ProductCard product={item} />}
      estimatedItemSize={100}  // Required: approximate item height
      keyExtractor={item => item.id}
    />
  )
}
// Average 56.9 FPS, 82% less CPU usage
```

**Required: estimatedItemSize**

```tsx
// FlashList requires estimatedItemSize for optimal recycling
<FlashList
  data={items}
  renderItem={renderItem}
  estimatedItemSize={120}  // Approximate height in pixels
  // If items vary greatly, use average height
/>

// For horizontal lists
<FlashList
  horizontal
  data={items}
  renderItem={renderItem}
  estimatedItemSize={200}  // Approximate width in pixels
/>
```

**Migration checklist:**

```tsx
// 1. Install FlashList
// npm install @shopify/flash-list

// 2. Replace import
// Before: import { FlatList } from 'react-native'
// After:  import { FlashList } from '@shopify/flash-list'

// 3. Add estimatedItemSize
// <FlashList estimatedItemSize={100} ... />

// 4. Ensure parent has flex: 1 or explicit height
<View style={{ flex: 1 }}>
  <FlashList ... />
</View>

// 5. Use keyExtractor (strongly recommended)
<FlashList keyExtractor={item => item.id} ... />
```

**When to stick with FlatList:**
- Very short lists (< 20 items)
- Lists where items have vastly different heights
- When you need SectionList features (use FlashList's section support instead)

Reference: [FlashList Documentation](https://shopify.github.io/flash-list/) | [Benchmarks](https://shopify.github.io/flash-list/docs/benchmarks)
