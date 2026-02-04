---
title: Use FlashList Instead of FlatList
impact: CRITICAL
impactDescription: 5-10× better FPS on Android
tags: list, flashlist, flatlist, virtualization
---

## Use FlashList Instead of FlatList

FlashList uses view recycling instead of creating new views for each item. This dramatically reduces memory allocation and improves scroll performance, especially on low-end Android devices where FlatList struggles.

**Incorrect (FlatList recreates views on scroll):**

```typescript
// screens/ProductList.tsx
import { FlatList } from 'react-native';

export function ProductList({ products }: Props) {
  return (
    <FlatList
      data={products}
      renderItem={({ item }) => <ProductCard product={item} />}
      keyExtractor={(item) => item.id}
    />
    // Each scroll creates/destroys views, causing jank on Android
  );
}
```

**Correct (FlashList recycles views):**

```typescript
// screens/ProductList.tsx
import { FlashList } from '@shopify/flash-list';

export function ProductList({ products }: Props) {
  return (
    <FlashList
      data={products}
      renderItem={({ item }) => <ProductCard product={item} />}
      keyExtractor={(item) => item.id}
      estimatedItemSize={120}
    />
    // Same views recycled, smooth 60 FPS scrolling
  );
}
```

**Migration:** FlashList is API-compatible with FlatList. Change the import and add `estimatedItemSize`.

**Performance gains:**
- 5× faster UI thread FPS on low-end Android
- 10× faster JS thread FPS
- 32% less CPU usage

Reference: [FlashList](https://shopify.github.io/flash-list/)
