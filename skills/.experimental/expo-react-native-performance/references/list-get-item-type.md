---
title: Use getItemType for Mixed Lists
impact: CRITICAL
impactDescription: 50% better recycling efficiency
tags: list, flashlist, item-type, heterogeneous
---

## Use getItemType for Mixed Lists

When a list contains different component types (headers, items, ads), FlashList can only recycle views of the same type. Provide `getItemType` to help FlashList maintain separate recycling pools for each type.

**Incorrect (no type differentiation):**

```typescript
// screens/Feed.tsx
type FeedItem = { type: 'post' | 'ad' | 'header'; data: any };

export function Feed({ items }: { items: FeedItem[] }) {
  return (
    <FlashList
      data={items}
      renderItem={({ item }) => {
        if (item.type === 'header') return <SectionHeader data={item.data} />;
        if (item.type === 'ad') return <AdBanner data={item.data} />;
        return <PostCard data={item.data} />;
      }}
      estimatedItemSize={200}
    />
    // FlashList can't recycle: header view becomes post view = layout thrashing
  );
}
```

**Correct (typed recycling pools):**

```typescript
// screens/Feed.tsx
type FeedItem = { type: 'post' | 'ad' | 'header'; data: any };

export function Feed({ items }: { items: FeedItem[] }) {
  return (
    <FlashList
      data={items}
      renderItem={({ item }) => {
        if (item.type === 'header') return <SectionHeader data={item.data} />;
        if (item.type === 'ad') return <AdBanner data={item.data} />;
        return <PostCard data={item.data} />;
      }}
      getItemType={(item) => item.type}
      estimatedItemSize={200}
    />
    // Posts recycle into posts, headers into headers
  );
}
```

**Result:** Each type maintains its own recycling pool, preventing expensive layout recalculations when items of different heights are recycled.

Reference: [FlashList getItemType](https://shopify.github.io/flash-list/docs/fundamentals/performant-components)
