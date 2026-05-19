---
title: Fall Back to Stale Cache When Fresh Fetch Fails
impact: HIGH
impactDescription: prevents temporary outages from becoming visible errors
tags: resilience, stale, fallback, cache, stale-if-error
---

## Fall Back to Stale Cache When Fresh Fetch Fails

If a recommendations endpoint flakes for 30 seconds, three options exist: (a) show an error and hide the carousel, (b) show a skeleton forever, (c) show the previously-cached recommendations and quietly retry in the background. Option (c) is the right answer for most non-critical data — the user sees content, the failure is invisible, and a successful retry replaces the stale data with fresh.

This is the `stale-if-error` directive from RFC 5861 applied client-side. Both TanStack Query and SWR can expose stale data on error; you just have to read `error` and `data` simultaneously.

**Incorrect (binary: success or error — no stale fallback):**

```tsx
function Recommendations() {
  const { data, error } = useQuery({
    queryKey: ['recommendations'],
    queryFn: fetchRecommendations,
  });

  if (error) return <ErrorBanner />;
  if (!data) return <Skeleton />;
  return <Carousel items={data} />;
}
// Endpoint flakes for 30s → user sees ErrorBanner for 30s for stale-but-fine data
```

**Correct (render stale on error, retry silently in background):**

```tsx
function Recommendations() {
  // `data` holds the last-successful response even when the most recent fetch failed
  const { data, error, isError, refetch } = useQuery({
    queryKey: ['recommendations'],
    queryFn: fetchRecommendations,
    retry: 2,
    retryDelay: attempt => Math.min(30_000, 1000 * 2 ** attempt) * Math.random(),
  });

  // We have stale data — render it even if the latest fetch errored
  if (data) {
    return (
      <>
        <Carousel items={data} />
        {isError && <small className="text-muted">(showing previous results)</small>}
      </>
    );
  }

  // No stale data either — only now show the failure
  if (error) return <ErrorBanner onRetry={refetch} />;
  return <Skeleton />;
}
```

**Server-side parallel (HTTP header):**

```http
Cache-Control: public, max-age=60, stale-if-error=86400
# If the origin returns 5xx, the cache serves stale content for up to 24h
```

**With persistence (survive page reload):**

```tsx
// Persist the query cache to localStorage for resilience across refreshes
import { persistQueryClient } from '@tanstack/react-query-persist-client';
import { createSyncStoragePersister } from '@tanstack/query-sync-storage-persister';

persistQueryClient({
  queryClient,
  persister: createSyncStoragePersister({ storage: window.localStorage }),
  maxAge: 24 * 60 * 60_000, // serve stale-up-to-1-day data after a reload
});
```

**When NOT to fall back to stale:**
- Cart contents and order totals — staleness can mislead at checkout
- Inventory (showing "in stock" when it's not creates support load)
- User-permission-sensitive data (showing the wrong account's data is a security issue)

**Tell the user the data is stale:** a tiny "last updated 2 min ago" timestamp lets them know they're seeing cached data without breaking the experience. Hidden staleness is technical debt; visible staleness is graceful degradation.

Reference: [RFC 5861 — stale-if-error](https://datatracker.ietf.org/doc/html/rfc5861#section-4) | [TanStack Query Persist Client](https://tanstack.com/query/latest/docs/framework/react/plugins/persistQueryClient)
