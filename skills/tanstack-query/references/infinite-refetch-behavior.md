---
title: Understand Infinite Query Refetch Behavior
impact: MEDIUM
impactDescription: prevents unexpected sequential refetches
tags: infinite, refetch, pages, behavior
---

## Understand Infinite Query Refetch Behavior

When an infinite query refetches, it refetches ALL pages sequentially. This can be slow with many pages. Use `maxPages` to limit this, or consider manual cache updates.

**Default behavior (sequential refetch):**

```typescript
const { data, refetch } = useInfiniteQuery({
  queryKey: ['posts'],
  queryFn: ({ pageParam }) => fetchPosts(pageParam),
  initialPageParam: 0,
  getNextPageParam: (lastPage) => lastPage.nextCursor,
})

// User has loaded 20 pages, then window focus triggers refetch:
// Page 1 → Page 2 → Page 3 → ... → Page 20 (sequential!)
// 20 network requests, one after another
```

**Mitigation 1: Use maxPages:**

```typescript
useInfiniteQuery({
  queryKey: ['posts'],
  queryFn: fetchPosts,
  maxPages: 5, // Only 5 sequential requests on refetch
  // ...
})
```

**Mitigation 2: Disable auto-refetch:**

```typescript
useInfiniteQuery({
  queryKey: ['posts'],
  queryFn: fetchPosts,
  refetchOnWindowFocus: false, // Don't refetch all pages on focus
  refetchOnMount: false,       // Don't refetch on remount
  staleTime: 5 * 60 * 1000,    // Stay fresh for 5 minutes
  // ...
})
```

**Mitigation 3: Manual first-page refetch:**

```typescript
function PostsList() {
  const queryClient = useQueryClient()
  const { data } = useInfiniteQuery({
    queryKey: ['posts'],
    queryFn: fetchPosts,
    refetchOnWindowFocus: false,
    // ...
  })

  // Manually refetch only the first page
  const refreshLatest = async () => {
    const firstPage = await fetchPosts({ pageParam: 0 })
    queryClient.setQueryData(['posts'], (old) => ({
      pages: [firstPage, ...(old?.pages.slice(1) ?? [])],
      pageParams: old?.pageParams ?? [0],
    }))
  }

  return (
    <div>
      <button onClick={refreshLatest}>Refresh</button>
      {/* ... */}
    </div>
  )
}
```
