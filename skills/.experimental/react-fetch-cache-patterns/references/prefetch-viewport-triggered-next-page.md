---
title: Prefetch the Next Page Before the Sentinel Hits Viewport
impact: HIGH
impactDescription: eliminates loading-more spinners in feeds
tags: prefetch, viewport, intersection-observer, infinite-scroll, feed
---

## Prefetch the Next Page Before the Sentinel Hits Viewport

A naive infinite scroll fires "fetch next page" when the sentinel element enters the viewport — at which point the user is already at the bottom, looking at empty space, waiting for the next batch. Instead, use `IntersectionObserver` with `rootMargin` to fire the prefetch when the sentinel is *N pixels below* the viewport. By the time the user scrolls to the bottom, the next page is already in cache.

`rootMargin: '500px'` to `'1000px'` is a good default for feeds — fires a viewport before the user gets there.

**Incorrect (sentinel at viewport bottom — user sees the spinner):**

```tsx
function Feed() {
  const { data, fetchNextPage, hasNextPage } = useInfiniteQuery({/* ... */});
  const sentinel = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!sentinel.current || !hasNextPage) return;
    const obs = new IntersectionObserver(([entry]) => {
      if (entry.isIntersecting) fetchNextPage();
    }); // no rootMargin → triggers at the moment of intersection
    obs.observe(sentinel.current);
    return () => obs.disconnect();
  }, [hasNextPage]);

  return <>{/* items */}<div ref={sentinel} /></>;
  // User scrolls to bottom → sees loading spinner for ~300ms
}
```

**Correct (rootMargin offsets the trigger upward):**

```tsx
function Feed() {
  const { data, fetchNextPage, hasNextPage, isFetchingNextPage } = useInfiniteQuery({
    queryKey: ['feed'],
    queryFn: ({ pageParam }) => fetchFeedPage(pageParam),
    initialPageParam: null,
    getNextPageParam: last => last.nextCursor,
  });
  const sentinel = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const el = sentinel.current;
    if (!el || !hasNextPage) return;
    const obs = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting && !isFetchingNextPage) fetchNextPage();
      },
      { rootMargin: '800px' } // fires when sentinel is 800px below viewport
    );
    obs.observe(el);
    return () => obs.disconnect();
  }, [hasNextPage, isFetchingNextPage, fetchNextPage]);

  return (
    <>
      {data?.pages.flatMap(p => p.items).map(item => <FeedItem key={item.id} {...item} />)}
      <div ref={sentinel} />
      {/* By the time the user scrolls here, the next page is rendered above */}
    </>
  );
}
```

**Tuning rootMargin:**
- Fast scrollers (mouse wheel, trackpad): 1000-2000px
- Touch devices: 500-800px
- Slow scrollers (e-readers, articles): 300-500px

Too aggressive (5000px) → prefetches pages the user never scrolls to. Too conservative (0px) → user sees the spinner.

**Guard against runaway prefetch:**

```tsx
// Stop prefetching when the user has loaded N pages without engaging (clicking an item)
if (data && data.pages.length >= 10 && !lastInteractionTime) {
  return null; // don't render the sentinel; require user to tap "load more" manually
}
```

**Why IntersectionObserver beats scroll math:** the browser does the geometry on the compositor thread; your JS doesn't run on every scroll frame. Lower CPU, smoother scroll.

Reference: [MDN — IntersectionObserver rootMargin](https://developer.mozilla.org/en-US/docs/Web/API/IntersectionObserver/rootMargin)
