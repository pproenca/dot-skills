---
title: Throttle Scroll-Triggered Fetches
impact: HIGH
impactDescription: reduces 60Hz event firing to 4-10Hz fetches
tags: protect, throttle, scroll, viewport, infinite-scroll
---

## Throttle Scroll-Triggered Fetches

Scroll events fire at ~60Hz (every 16ms). Binding a "load more when near bottom" check to every event runs the check 60x per second — and if the check involves a fetch trigger, you can fire multiple "load next page" requests before the first one resolves. Throttle: ensure the check runs at most every N milliseconds.

Better still: use `IntersectionObserver` for viewport-triggered fetches. It's natively throttled by the browser and runs on the compositor thread, not the main thread.

**Incorrect (scroll handler fetches on every event):**

```tsx
function Feed() {
  const handleScroll = () => {
    if (window.scrollY + window.innerHeight > document.body.scrollHeight - 500) {
      loadNextPage(); // can fire 30+ times before first request completes
    }
  };
  useEffect(() => {
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);
}
```

**Correct (IntersectionObserver — viewport-triggered, native throttling):**

```tsx
function Feed() {
  const { fetchNextPage, hasNextPage, isFetchingNextPage } = useInfiniteQuery({
    queryKey: ['feed'],
    queryFn: ({ pageParam }) => fetchFeed({ cursor: pageParam }),
    initialPageParam: null,
    getNextPageParam: lastPage => lastPage.nextCursor,
  });

  const sentinelRef = useRef<HTMLDivElement>(null);
  useEffect(() => {
    const el = sentinelRef.current;
    if (!el || !hasNextPage) return;
    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting && !isFetchingNextPage) fetchNextPage();
      },
      { rootMargin: '500px' } // pre-fetch when sentinel is 500px from viewport
    );
    observer.observe(el);
    return () => observer.disconnect();
  }, [hasNextPage, isFetchingNextPage, fetchNextPage]);

  return (
    <>
      <FeedItems />
      <div ref={sentinelRef} /> {/* sentinel; observer fires once when visible */}
    </>
  );
}
```

**If you must use scroll events (throttle utility):**

```ts
export function throttle<A extends unknown[]>(fn: (...args: A) => void, ms: number) {
  let last = 0;
  let timer: ReturnType<typeof setTimeout> | null = null;
  return (...args: A) => {
    const now = Date.now();
    const remaining = ms - (now - last);
    if (remaining <= 0) {
      if (timer) { clearTimeout(timer); timer = null; }
      last = now;
      fn(...args);
    } else if (!timer) {
      timer = setTimeout(() => { last = Date.now(); timer = null; fn(...args); }, remaining);
    }
  };
}
```

**Guard against double-fires:** even with throttling, check `isFetchingNextPage` before calling — a slow backend can let two trigger windows fire before the first response arrives.

Reference: [MDN — IntersectionObserver](https://developer.mozilla.org/en-US/docs/Web/API/Intersection_Observer_API)
