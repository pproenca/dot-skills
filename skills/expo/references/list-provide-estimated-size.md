---
title: Provide Accurate estimatedItemSize for FlashList
impact: HIGH
impactDescription: eliminates layout recalculation, smoother initial render
tags: list, flashlist, estimatedItemSize, layout
---

## Provide Accurate estimatedItemSize for FlashList

FlashList uses `estimatedItemSize` to pre-calculate scroll positions and optimize rendering. An accurate estimate prevents layout jumps and improves initial render performance.

**Incorrect (missing or inaccurate estimate):**

```typescript
import { FlashList } from '@shopify/flash-list'

function MessageList({ messages }) {
  return (
    <FlashList
      data={messages}
      renderItem={({ item }) => <MessageBubble message={item} />}
      // Missing estimatedItemSize - FlashList will warn
    />
  )
}
```

**Correct (measured estimate):**

```typescript
import { FlashList } from '@shopify/flash-list'

function MessageList({ messages }) {
  return (
    <FlashList
      data={messages}
      renderItem={({ item }) => <MessageBubble message={item} />}
      estimatedItemSize={85}  // Measured average height
    />
  )
}

// How to measure: render a few items and log their heights
// <View onLayout={(e) => console.log(e.nativeEvent.layout.height)}>
```

**For variable height items, use getItemType:**

```typescript
import { FlashList } from '@shopify/flash-list'

function FeedList({ items }) {
  return (
    <FlashList
      data={items}
      renderItem={({ item }) => {
        if (item.type === 'image') return <ImagePost post={item} />
        if (item.type === 'video') return <VideoPost post={item} />
        return <TextPost post={item} />
      }}
      getItemType={item => item.type}
      estimatedItemSize={200}  // Average across all types
    />
  )
}
```

**Note:** FlashList v2+ with New Architecture handles item sizing automatically. This rule applies to FlashList v1 or when using `legacyImplementation`. Check performance warnings in development mode for sizing issues.

Reference: [FlashList estimatedItemSize](https://shopify.github.io/flash-list/docs/usage#estimateditemsize)
