---
title: Use Stale-While-Revalidate for Instant Renders
impact: CRITICAL
impactDescription: 0ms perceived wait for cached data
tags: cache, swr, stale-while-revalidate, ux
---

## Use Stale-While-Revalidate for Instant Renders

The SWR pattern (RFC 5861): when stale data exists, return it instantly *and* fetch fresh data in the background. The user sees the page immediately, then the cards smoothly update if the fresh data differs. The alternative — showing a skeleton while refetching — punishes the user for already having the data.

Both SWR and TanStack Query implement this; it's the default behavior when `staleTime` has elapsed but `gcTime` hasn't. The pattern's superpower: navigating back to a list you've seen renders the list immediately rather than the loading state.

**Incorrect (block on revalidation — back-button shows skeleton):**

```tsx
function ProductList() {
  const { data, isLoading } = useQuery({
    queryKey: ['products'],
    queryFn: fetchProducts,
    // No cached data exposed during revalidation
  });
  // After staleTime elapses, isLoading flips true on next mount even though we have data
  if (isLoading) return <Skeleton />; // jarring flicker on every revisit
  return <List products={data!} />;
}
```

**Correct (render stale instantly, fade in fresh):**

```tsx
function ProductList() {
  const { data, isFetching, isPlaceholderData } = useQuery({
    queryKey: ['products'],
    queryFn: fetchProducts,
    staleTime: 60_000,         // 1 min "fresh" window
    placeholderData: keepPreviousData, // for paginated/filtered queries
  });

  // First mount: data is undefined → show skeleton
  // Subsequent mounts: data is the cached value, isFetching may be true → render instantly
  if (!data) return <Skeleton />;
  return (
    <>
      <List products={data} className={isFetching ? 'opacity-90' : ''} />
      {isFetching && <RefreshIndicator />}
    </>
  );
}
```

**For filtered/paginated lists (keep previous results during refetch):**

```tsx
const { data, isPlaceholderData } = useQuery({
  queryKey: ['products', { filter }],
  queryFn: () => fetchProducts(filter),
  placeholderData: keepPreviousData, // when filter changes, show old results until new ones land
});
// Filtering doesn't flash an empty state; only after new data resolves does the list update.
```

**Server-side equivalent (HTTP header):**

```http
Cache-Control: public, max-age=0, stale-while-revalidate=600
# Browser/CDN serves stale data instantly and revalidates in the background up to 10 min
```

Reference: [Vercel — Stale-While-Revalidate](https://web.dev/articles/stale-while-revalidate) | [RFC 5861](https://datatracker.ietf.org/doc/html/rfc5861)
