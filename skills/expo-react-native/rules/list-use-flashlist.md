---
title: Use FlashList Instead of FlatList for Large Lists
impact: HIGH
impactDescription: 54% FPS improvement, 82% CPU reduction via cell recycling
tags: list, flashlist, flatlist, virtualization, recycling
---

## Use FlashList Instead of FlatList for Large Lists

FlashList uses cell recycling like native iOS UITableView and Android RecyclerView, dramatically reducing memory usage and improving scroll performance compared to FlatList's virtualization.

**Incorrect (FlatList for large datasets):**

```typescript
import { FlatList } from 'react-native'

function ProductList({ products }) {
  return (
    <FlatList
      data={products}  // 1000+ items
      renderItem={({ item }) => <ProductCard product={item} />}
      keyExtractor={item => item.id}
    />
  )
}
// FlatList mounts/unmounts components, causing jank during fast scrolling
```

**Correct (FlashList with cell recycling):**

```typescript
import { FlashList } from '@shopify/flash-list'

function ProductList({ products }) {
  return (
    <FlashList
      data={products}
      renderItem={({ item }) => <ProductCard product={item} />}
      estimatedItemSize={120}  // Required: approximate item height
      keyExtractor={item => item.id}
    />
  )
}
// FlashList reuses components, maintaining smooth 60fps
```

**Installation:**

```bash
npx expo install @shopify/flash-list
```

**Performance metrics (FlashList v1 benchmarks):**
| Metric | FlatList | FlashList |
|--------|----------|-----------|
| Average FPS | 36.9 | 56.9 |
| CPU Usage | 198.9% | 36.5% |
| JS Thread | >90% | <10% |

**Note:** FlashList v2+ (2025) with New Architecture provides further improvements and automatic item sizing.

**When to use FlatList:**
- Lists with < 50 simple items
- Highly dynamic item heights that can't be estimated
- When FlashList compatibility issues arise

Reference: [FlashList Documentation](https://shopify.github.io/flash-list/)
