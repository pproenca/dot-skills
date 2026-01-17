---
title: Configure List Batch Rendering for Scroll Performance
impact: MEDIUM-HIGH
impactDescription: reduces blank areas during fast scrolling
tags: list, flatlist, batching, windowSize, maxToRenderPerBatch
---

## Configure List Batch Rendering for Scroll Performance

Tune FlatList's batch rendering props to balance memory usage against scroll smoothness. The defaults are conservative and may show blank areas during fast scrolling.

**Incorrect (default settings cause blank areas):**

```typescript
import { FlatList } from 'react-native'

function ArticleList({ articles }) {
  return (
    <FlatList
      data={articles}
      renderItem={({ item }) => <ArticleCard article={item} />}
      keyExtractor={item => item.id}
      // Default: windowSize=21, maxToRenderPerBatch=10
      // May show blank areas on fast scroll
    />
  )
}
```

**Correct (tuned for fast scrolling):**

```typescript
import { FlatList } from 'react-native'

function ArticleList({ articles }) {
  return (
    <FlatList
      data={articles}
      renderItem={({ item }) => <ArticleCard article={item} />}
      keyExtractor={item => item.id}
      windowSize={11}  // Render 5 screens above and below
      maxToRenderPerBatch={5}  // Render 5 items per batch
      updateCellsBatchingPeriod={50}  // 50ms between batches
      initialNumToRender={10}  // Initial visible items
      removeClippedSubviews={true}  // Unmount off-screen items
    />
  )
}
```

**Configuration guide:**

| Prop | Lower Value | Higher Value |
|------|-------------|--------------|
| windowSize | Less memory, more blanks | More memory, fewer blanks |
| maxToRenderPerBatch | Smoother UI, more blanks | More blanks during scroll, faster fill |
| initialNumToRender | Faster initial render | Better initial scroll |

**For different use cases:**

```typescript
// Memory-constrained (long lists, complex items)
windowSize={5}
maxToRenderPerBatch={3}

// Smooth scrolling priority (short lists, simple items)
windowSize={21}
maxToRenderPerBatch={10}
```

**Note:** FlashList handles batching automatically and usually doesn't need these tweaks. Prefer FlashList for new code.

Reference: [Optimizing FlatList Configuration](https://reactnative.dev/docs/optimizing-flatlist-configuration)
