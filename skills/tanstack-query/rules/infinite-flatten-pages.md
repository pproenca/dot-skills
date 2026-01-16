---
title: Flatten Pages for Rendering
impact: MEDIUM
impactDescription: simplifies component logic, enables virtualization
tags: infinite, pages, flatMap, rendering
---

## Flatten Pages for Rendering

`useInfiniteQuery` returns data as `{ pages: Page[], pageParams: unknown[] }`. Flatten to a single array for rendering and enable virtualization libraries.

**Incorrect (nested rendering):**

```typescript
function PostsList() {
  const { data } = useInfiniteQuery({
    queryKey: ['posts'],
    queryFn: fetchPosts,
    // ...
  })

  return (
    <div>
      {data?.pages.map((page, pageIndex) => (
        // Extra wrapper divs, harder to virtualize
        <div key={pageIndex}>
          {page.items.map(post => (
            <PostCard key={post.id} post={post} />
          ))}
        </div>
      ))}
    </div>
  )
}
```

**Correct (flattened array):**

```typescript
function PostsList() {
  const { data } = useInfiniteQuery({
    queryKey: ['posts'],
    queryFn: fetchPosts,
    // ...
  })

  // Flatten once, memoized
  const allPosts = useMemo(
    () => data?.pages.flatMap(page => page.items) ?? [],
    [data?.pages]
  )

  return (
    <div>
      {allPosts.map(post => (
        <PostCard key={post.id} post={post} />
      ))}
    </div>
  )
}
```

**With virtualization:**

```typescript
import { useVirtualizer } from '@tanstack/react-virtual'

function VirtualizedPostsList() {
  const { data, fetchNextPage, hasNextPage, isFetchingNextPage } = useInfiniteQuery({
    queryKey: ['posts'],
    queryFn: fetchPosts,
    // ...
  })

  const allPosts = useMemo(
    () => data?.pages.flatMap(page => page.items) ?? [],
    [data?.pages]
  )

  const parentRef = useRef<HTMLDivElement>(null)
  const virtualizer = useVirtualizer({
    count: hasNextPage ? allPosts.length + 1 : allPosts.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 100,
  })

  useEffect(() => {
    const lastItem = virtualizer.getVirtualItems().at(-1)
    if (lastItem?.index >= allPosts.length - 1 && hasNextPage && !isFetchingNextPage) {
      fetchNextPage()
    }
  }, [virtualizer.getVirtualItems(), hasNextPage, isFetchingNextPage, fetchNextPage, allPosts.length])

  return (
    <div ref={parentRef} style={{ height: '500px', overflow: 'auto' }}>
      <div style={{ height: virtualizer.getTotalSize() }}>
        {virtualizer.getVirtualItems().map(virtualRow => (
          <PostCard
            key={allPosts[virtualRow.index]?.id ?? 'loader'}
            post={allPosts[virtualRow.index]}
            style={{ transform: `translateY(${virtualRow.start}px)` }}
          />
        ))}
      </div>
    </div>
  )
}
```
