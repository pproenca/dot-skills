---
title: Limit Infinite Query Pages with maxPages
impact: HIGH
impactDescription: 90% memory reduction in long sessions
tags: infinite, maxPages, memory, pagination
---

## Limit Infinite Query Pages with maxPages

Without `maxPages`, infinite queries accumulate all pages in memory indefinitely. After 50+ pages, memory bloats and refetching all pages serially causes severe performance degradation.

**Incorrect (unbounded pages):**

```typescript
const { data, fetchNextPage } = useInfiniteQuery({
  queryKey: ['posts'],
  queryFn: ({ pageParam }) => fetchPosts(pageParam),
  initialPageParam: 0,
  getNextPageParam: (lastPage) => lastPage.nextCursor,
  // No maxPages - accumulates forever!
})

// User scrolls through 100 pages:
// - 100 pages in memory
// - Refetch takes 100 sequential requests
// - Memory grows unbounded
```

**Correct (bounded with maxPages):**

```typescript
const { data, fetchNextPage, fetchPreviousPage } = useInfiniteQuery({
  queryKey: ['posts'],
  queryFn: ({ pageParam }) => fetchPosts(pageParam),
  initialPageParam: 0,
  getNextPageParam: (lastPage) => lastPage.nextCursor,
  getPreviousPageParam: (firstPage) => firstPage.prevCursor,
  maxPages: 5, // Keep only 5 pages in memory
})

// User scrolls through 100 pages:
// - Only 5 pages in memory at any time
// - Refetch is 5 requests, not 100
// - Bidirectional scrolling works with getPreviousPageParam
```

**Choose maxPages based on UX:**

```typescript
// Chat: users scroll back frequently, keep more
maxPages: 10,

// Feed: users rarely scroll back, keep less
maxPages: 3,

// Dashboard tables: virtualized, keep minimal
maxPages: 2,
```

**Handle page eviction in UI:**

```typescript
function PostsList() {
  const { data, fetchPreviousPage, hasPreviousPage } = useInfiniteQuery({
    queryKey: ['posts'],
    // ...
    maxPages: 5,
    getPreviousPageParam: (firstPage) => firstPage.prevCursor,
  })

  return (
    <div>
      {hasPreviousPage && (
        <button onClick={() => fetchPreviousPage()}>
          Load earlier posts
        </button>
      )}
      {data.pages.flatMap(page => page.items).map(post => (
        <PostCard key={post.id} post={post} />
      ))}
    </div>
  )
}
```

Reference: [Infinite Queries](https://tanstack.com/query/v5/docs/react/guides/infinite-queries)
