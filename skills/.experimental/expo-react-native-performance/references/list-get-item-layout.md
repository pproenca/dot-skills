---
title: Provide getItemLayout for Fixed Heights
impact: CRITICAL
impactDescription: eliminates async layout calculation
tags: list, flatlist, layout, fixed-height
---

## Provide getItemLayout for Fixed Heights

When all list items have the same height, provide `getItemLayout` to skip asynchronous measurement. FlatList/FlashList can instantly calculate scroll position without rendering off-screen items.

**Incorrect (FlatList measures each item):**

```typescript
// screens/NotificationList.tsx
const ITEM_HEIGHT = 72;

export function NotificationList({ notifications }: Props) {
  return (
    <FlatList
      data={notifications}
      renderItem={({ item }) => (
        <NotificationRow notification={item} style={{ height: ITEM_HEIGHT }} />
      )}
      keyExtractor={(item) => item.id}
    />
    // FlatList renders items to measure them, causing scroll jank
  );
}
```

**Correct (skip measurement with getItemLayout):**

```typescript
// screens/NotificationList.tsx
const ITEM_HEIGHT = 72;

export function NotificationList({ notifications }: Props) {
  const getItemLayout = useCallback(
    (_: any, index: number) => ({
      length: ITEM_HEIGHT,
      offset: ITEM_HEIGHT * index,
      index,
    }),
    []
  );

  return (
    <FlatList
      data={notifications}
      renderItem={({ item }) => (
        <NotificationRow notification={item} style={{ height: ITEM_HEIGHT }} />
      )}
      keyExtractor={(item) => item.id}
      getItemLayout={getItemLayout}
    />
    // Instant scroll position calculation, no measurement needed
  );
}
```

**When NOT to use:** Items with dynamic heights (text wrapping, images). Use FlashList with `estimatedItemSize` instead.

Reference: [Optimizing FlatList](https://reactnative.dev/docs/optimizing-flatlist-configuration)
