---
title: Handle Infinite Query Loading States Correctly
impact: MEDIUM
impactDescription: prevents UI glitches, shows appropriate feedback
tags: infinite, loading, isFetchingNextPage, isPending
---

## Handle Infinite Query Loading States Correctly

Infinite queries have multiple loading states: initial load, fetching next page, and background refetch. Using the wrong state causes spinners in wrong places.

**Incorrect (wrong loading indicator):**

```typescript
function PostsList() {
  const { data, isPending, fetchNextPage, hasNextPage } = useInfiniteQuery({
    queryKey: ['posts'],
    queryFn: fetchPosts,
    // ...
  })

  // isPending is true during initial load AND fetchNextPage!
  if (isPending) return <FullPageSpinner /> // Flashes on load more

  return (
    <div>
      {data.pages.flatMap(p => p.items).map(post => (
        <PostCard key={post.id} post={post} />
      ))}
      <button onClick={() => fetchNextPage()}>
        Load More
      </button>
    </div>
  )
}
```

**Correct (distinct loading states):**

```typescript
function PostsList() {
  const {
    data,
    isPending,           // True only during initial load
    isFetchingNextPage,  // True only during fetchNextPage
    isFetching,          // True during any fetch (including background)
    hasNextPage,
    fetchNextPage,
  } = useInfiniteQuery({
    queryKey: ['posts'],
    queryFn: fetchPosts,
    // ...
  })

  // Initial load
  if (isPending) return <FullPageSpinner />

  const allPosts = data.pages.flatMap(p => p.items)

  return (
    <div>
      {/* Background refetch indicator */}
      {isFetching && !isFetchingNextPage && (
        <div className="absolute top-0 right-0">
          <RefreshSpinner />
        </div>
      )}

      {allPosts.map(post => (
        <PostCard key={post.id} post={post} />
      ))}

      {/* Load more button with loading state */}
      {hasNextPage && (
        <button
          onClick={() => fetchNextPage()}
          disabled={isFetchingNextPage}
        >
          {isFetchingNextPage ? 'Loading...' : 'Load More'}
        </button>
      )}

      {/* End of list indicator */}
      {!hasNextPage && <div>No more posts</div>}
    </div>
  )
}
```

**Loading state summary:**

| State | Initial Load | Fetch Next | Background Refetch |
|-------|--------------|------------|-------------------|
| isPending | ✓ | ✗ | ✗ |
| isFetchingNextPage | ✗ | ✓ | ✗ |
| isFetching | ✓ | ✓ | ✓ |
