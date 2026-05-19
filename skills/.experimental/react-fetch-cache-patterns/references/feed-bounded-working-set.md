---
title: Bound the In-Memory Working Set on Long Feeds
impact: MEDIUM-HIGH
impactDescription: prevents unbounded memory growth on infinite scroll
tags: feed, memory, working-set, infinite-scroll, eviction
---

## Bound the In-Memory Working Set on Long Feeds

A user who scrolls through 50 pages of a feed accumulates 50 pages × 30 items = 1500 cached items, even with virtualization. The DOM is bounded by virtualization, but the JS heap is not — image objects, cached query results, and normalized entity records grow without limit. On mobile, this triggers OOM kills; on desktop, GC pauses cause scroll jank.

Bound the cache: after page N+5, drop the oldest pages from the infinite-query cache and the entity store. The user can always re-scroll; the entities they care about (favorites, viewed items) are kept separately.

**Incorrect (unbounded growth — JS heap balloons on long scroll):**

```tsx
function Feed() {
  const { data } = useInfiniteQuery({
    queryKey: ['feed'],
    queryFn: ({ pageParam }) => fetchFeedPage(pageParam),
    initialPageParam: null,
    getNextPageParam: last => last.nextCursor,
    // No maxPages — pages accumulate forever
  });
}
```

**Correct (bounded with maxPages — old pages drop as new ones load):**

```tsx
function Feed() {
  const { data } = useInfiniteQuery({
    queryKey: ['feed'],
    queryFn: ({ pageParam }) => fetchFeedPage(pageParam),
    initialPageParam: null,
    getNextPageParam: last => last.nextCursor,
    getPreviousPageParam: first => first.prevCursor,
    maxPages: 8, // keep at most 8 pages × 30 items = 240 items in memory
  });
  // When fetchNextPage exceeds maxPages, the oldest page is dropped from data.pages
  // If the user scrolls back, fetchPreviousPage refetches it
}
```

**Pair virtualization with cache eviction (memory-bounded scroll without losing position):**

```tsx
function BoundedFeed() {
  const parentRef = useRef<HTMLDivElement>(null);
  const { data, fetchNextPage, fetchPreviousPage, hasNextPage, hasPreviousPage } =
    useInfiniteQuery({ /* ...with maxPages: 8, getPreviousPageParam ... */ });

  const allItems = data?.pages.flatMap(p => p.items) ?? [];

  const virtualizer = useVirtualizer({
    count: allItems.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 120,
    overscan: 5,
    // When the user scrolls UP past the start of cached pages, fetch previous
    onChange: (instance) => {
      const first = instance.getVirtualItems()[0];
      if (first && first.index < 5 && hasPreviousPage) fetchPreviousPage();
    },
  });
}
```

**For normalized entity stores (cap by recency + pinning):**

```ts
// Pseudocode: LRU eviction with pinned items
class EntityStore<T extends { id: string }> {
  private items = new Map<string, T>();
  private order: string[] = [];     // most-recent first
  private pinned = new Set<string>(); // never evict (favorites, recently-viewed)

  constructor(private maxSize: number) {}

  set(id: string, value: T) {
    this.items.set(id, value);
    this.order = [id, ...this.order.filter(i => i !== id)];
    this.evict();
  }

  pin(id: string) { this.pinned.add(id); }

  private evict() {
    while (this.order.length > this.maxSize) {
      const candidate = [...this.order].reverse().find(id => !this.pinned.has(id));
      if (!candidate) break;
      this.items.delete(candidate);
      this.order = this.order.filter(i => i !== candidate);
    }
  }
}
```

**Mobile-specific consideration:** iOS Safari kills tabs at ~1GB JS heap. Native apps see OS-level memory warnings at ~150MB. Bound the working set aggressively on mobile: `maxPages: 4` instead of 8, no large blurred-image placeholders.

**Image-specific cleanup:** even when items drop from the data cache, the browser may keep image bitmaps. For very long-running feeds, periodically clear `URL.revokeObjectURL` for blob: URLs you created, and avoid keeping references to image elements.

Reference: [TanStack Query — maxPages](https://tanstack.com/query/latest/docs/framework/react/guides/infinite-queries#what-if-i-want-to-limit-the-number-of-pages)
