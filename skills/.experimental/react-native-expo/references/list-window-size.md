---
title: Tune windowSize for Memory vs Performance
impact: HIGH
impactDescription: 30-50% memory reduction with proper tuning
tags: list, flatlist, windowSize, virtualization, memory
---

## Tune windowSize for Memory vs Performance

`windowSize` controls how many screens of content are rendered outside the viewport. Balance between memory and scroll smoothness.

**Incorrect (default may not fit use case):**

```tsx
// Default windowSize=21 (10 screens above + 1 visible + 10 below)
<FlatList
  data={largeDataset}
  renderItem={renderComplexItem}
/>
// May use too much memory with complex items
// Or show blank areas if items are very tall
```

**Correct (tuned for content type):**

```tsx
// For simple items (text lists, settings)
// Lower windowSize saves memory
<FlatList
  data={contacts}
  renderItem={renderContactRow}
  windowSize={5}  // 2 + 1 + 2 screens
  // Less memory, acceptable for simple items
/>

// For complex items (cards with images)
// Higher windowSize prevents blanks during fast scroll
<FlatList
  data={posts}
  renderItem={renderPostCard}
  windowSize={11}  // 5 + 1 + 5 screens
  maxToRenderPerBatch={5}
  updateCellsBatchingPeriod={50}
/>

// For very large items (full-screen pages)
<FlatList
  data={pages}
  renderItem={renderFullPage}
  windowSize={3}  // 1 + 1 + 1 screens
  // Minimal memory for large items
/>
```

**Combine with related props:**

```tsx
<FlatList
  data={items}
  renderItem={renderItem}
  // Virtualization window
  windowSize={7}  // Screens to keep mounted

  // Batch rendering
  initialNumToRender={10}  // Items for first render
  maxToRenderPerBatch={10}  // Items per scroll batch
  updateCellsBatchingPeriod={50}  // ms between batches

  // Memory optimization
  removeClippedSubviews={true}  // Detach off-screen views

  // Performance monitoring
  onEndReachedThreshold={0.5}  // Load more at 50% from end
/>
```

**Guidelines by content type:**

| Content | windowSize | initialNumToRender | maxToRenderPerBatch |
|---------|------------|-------------------|---------------------|
| Simple text rows | 5 | 20 | 20 |
| Cards with images | 7-11 | 10 | 10 |
| Complex multimedia | 5-7 | 5 | 5 |
| Full-screen pages | 3 | 2 | 2 |

**Testing approach:**

```tsx
// Start conservative, increase if you see blanks
const [windowSize, setWindowSize] = useState(5)

// Monitor performance
<FlatList
  windowSize={windowSize}
  onScrollBeginDrag={() => console.log('scroll start')}
  onMomentumScrollEnd={() => console.log('scroll end')}
/>
```

Reference: [FlatList windowSize Documentation](https://reactnative.dev/docs/flatlist#windowsize)
