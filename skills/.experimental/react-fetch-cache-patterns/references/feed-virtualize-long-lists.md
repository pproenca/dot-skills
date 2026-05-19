---
title: Virtualize Long Lists Beyond ~50 Items
impact: MEDIUM-HIGH
impactDescription: 10-100× fewer DOM nodes
tags: feed, virtualization, tanstack-virtual, performance
---

## Virtualize Long Lists Beyond ~50 Items

Mounting 2000 list items creates 2000 React fibers, 2000 DOM nodes, and 2000 subscriptions to anything those items use. Scrolling becomes janky; updates cascade through every row. Virtualization renders only the items currently in (or near) the viewport — typically 20-50 — and recycles them as the user scrolls.

The threshold is around 50 items for medium-complexity rows; below that, virtualization's overhead isn't worth it. Above 200, it becomes essential.

**Incorrect (render all items — DOM blows up):**

```tsx
function Feed({ items }: { items: Item[] }) {
  // 2000 items = 2000 DOM rows. Initial paint ~800ms; scroll FPS plummets.
  return items.map(item => <FeedRow key={item.id} item={item} />);
}
```

**Correct (virtualize with TanStack Virtual):**

```tsx
import { useVirtualizer } from '@tanstack/react-virtual';

function Feed({ items }: { items: Item[] }) {
  const parentRef = useRef<HTMLDivElement>(null);

  const virtualizer = useVirtualizer({
    count: items.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 120, // approximate row height
    overscan: 5,             // render 5 extra above/below viewport for smoother scroll
  });

  return (
    <div ref={parentRef} style={{ height: 600, overflow: 'auto' }}>
      <div style={{ height: virtualizer.getTotalSize(), position: 'relative' }}>
        {virtualizer.getVirtualItems().map(vRow => (
          <div
            key={vRow.key}
            data-index={vRow.index}
            ref={virtualizer.measureElement} // dynamic row heights work too
            style={{
              position: 'absolute',
              top: 0,
              left: 0,
              width: '100%',
              transform: `translateY(${vRow.start}px)`,
            }}
          >
            <FeedRow item={items[vRow.index]} />
          </div>
        ))}
      </div>
    </div>
  );
}
// Only ~25 rows mounted regardless of total. Constant memory; smooth scroll.
```

**Combine with infinite query for paginated feeds:**

```tsx
const { data, fetchNextPage, hasNextPage } = useInfiniteQuery({/* ... */});
const allItems = useMemo(
  () => data?.pages.flatMap(p => p.items) ?? [],
  [data]
);

const virtualizer = useVirtualizer({
  count: hasNextPage ? allItems.length + 1 : allItems.length, // +1 sentinel slot
  getScrollElement: () => parentRef.current,
  estimateSize: () => 120,
});

// In the row renderer:
const vRow = virtualizer.getVirtualItems().at(-1);
useEffect(() => {
  if (!vRow) return;
  if (vRow.index >= allItems.length - 1 && hasNextPage) fetchNextPage();
}, [vRow?.index, allItems.length, hasNextPage]);
```

**When NOT to virtualize:**
- Lists shorter than 50 items — virtualization overhead isn't worth it
- Items with very irregular content (rich text articles) — measurement is expensive
- Content that needs to print or be SEO-indexed — virtualized items are invisible to crawlers and `Ctrl-F`

**Trade-offs to plan for:**
- `Ctrl-F` doesn't find off-screen items by default (consider headless mode for print)
- Anchor links and scroll-into-view require `scrollToIndex()` calls
- Screen readers need ARIA live regions or `aria-rowcount` to understand virtualization

Reference: [TanStack Virtual](https://tanstack.com/virtual/latest)
