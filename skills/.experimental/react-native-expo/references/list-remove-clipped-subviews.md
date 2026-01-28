---
title: Enable removeClippedSubviews for Long Lists
impact: MEDIUM
impactDescription: reduces memory usage for off-screen items
tags: list, flatlist, removeClippedSubviews, memory, android
---

## Enable removeClippedSubviews for Long Lists

`removeClippedSubviews` detaches native views that are outside the viewport, reducing memory pressure on long lists.

**Incorrect (all views stay in memory):**

```tsx
<FlatList
  data={thousandsOfItems}
  renderItem={renderItem}
  // Default: removeClippedSubviews={false} on iOS
  // All rendered views stay in native view hierarchy
/>
// Memory grows as user scrolls through long list
```

**Correct (off-screen views detached):**

```tsx
<FlatList
  data={thousandsOfItems}
  renderItem={renderItem}
  removeClippedSubviews={true}  // Enable native view recycling
  // Off-screen views detached from native hierarchy
  // Re-attached when scrolled back into view
/>
```

**Platform behavior:**

```tsx
// Android: enabled by default, generally safe
// iOS: disabled by default, can cause issues

// Safe pattern for both platforms
<FlatList
  data={items}
  renderItem={renderItem}
  removeClippedSubviews={Platform.OS === 'android'}
  // Or enable on iOS only after testing:
  // removeClippedSubviews={true}
/>
```

**Caveats on iOS:**

```tsx
// May cause issues with:
// - Sticky headers
// - Items with position: 'absolute'
// - Transform animations on items
// - Items that extend outside their bounds

// If you see visual glitches on iOS, disable it:
<FlatList
  removeClippedSubviews={false}
  // ...
/>
```

**Combine with other memory optimizations:**

```tsx
<FlatList
  data={items}
  renderItem={renderItem}
  // Memory optimizations
  removeClippedSubviews={true}
  windowSize={5}  // Fewer items rendered

  // Rendering optimizations
  maxToRenderPerBatch={10}
  updateCellsBatchingPeriod={50}
  initialNumToRender={10}

  // Enable native view recycling
  getItemLayout={getItemLayout}  // If fixed height
/>
```

**When NOT to use:**
- Sticky headers that must stay visible
- Items with complex animations
- iOS apps with visual glitches when enabled
- Lists with items that render outside their bounds

Reference: [FlatList removeClippedSubviews](https://reactnative.dev/docs/flatlist#removeclippedsubviews)
