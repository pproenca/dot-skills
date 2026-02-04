---
title: Provide Accurate estimatedItemSize
impact: CRITICAL
impactDescription: prevents blank cells during fast scroll
tags: list, flashlist, estimated-size, virtualization
---

## Provide Accurate estimatedItemSize

FlashList uses `estimatedItemSize` to calculate how many items to render initially and during scroll. An inaccurate estimate causes blank cells or excessive memory usage. Measure your actual item height and provide it.

**Incorrect (default or guessed estimate):**

```typescript
// screens/MessageList.tsx
export function MessageList({ messages }: Props) {
  return (
    <FlashList
      data={messages}
      renderItem={({ item }) => <MessageBubble message={item} />}
      estimatedItemSize={50}  // Wrong: actual messages are ~150px tall
    />
    // Blank cells appear during fast scrolling
  );
}
```

**Correct (measured average height):**

```typescript
// screens/MessageList.tsx
export function MessageList({ messages }: Props) {
  return (
    <FlashList
      data={messages}
      renderItem={({ item }) => <MessageBubble message={item} />}
      estimatedItemSize={150}  // Measured from actual rendered items
    />
    // Smooth scrolling with no blank cells
  );
}
```

**How to measure:**
1. Add `onLayout` to your list item temporarily
2. Log the `event.nativeEvent.layout.height`
3. Average across multiple items
4. Use the median value for varied-height lists

**For mixed content:** Use the average height. FlashList v2 removes the need for estimates entirely.

Reference: [FlashList estimatedItemSize](https://shopify.github.io/flash-list/docs/fundamentals/performant-components)
