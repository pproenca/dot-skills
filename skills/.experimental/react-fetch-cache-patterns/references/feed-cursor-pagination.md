---
title: Use Cursor Pagination over Offset
impact: MEDIUM-HIGH
impactDescription: prevents skip/duplicate items as the list shifts
tags: feed, cursor, pagination, offset, consistency
---

## Use Cursor Pagination over Offset

Offset pagination (`?page=2&size=20` or `LIMIT 20 OFFSET 40`) has two problems at scale: (1) the backend re-scans rows 0-39 just to return rows 40-59 — `OFFSET 100000` is brutal on the database; (2) when new items are inserted between page fetches (very common in feeds), the user sees duplicate or skipped items because page boundaries shift. Cursor pagination uses an opaque cursor pointing to "the item after which to continue" — stable across inserts, indexable, fast.

Use cursors for any feed where new items can appear between page fetches.

**Incorrect (offset pagination — duplicates and skips on inserts):**

```ts
async function fetchFeedPage(page: number): Promise<{ items: Post[]; nextPage: number | null }> {
  const res = await fetch(`/api/feed?page=${page}&size=20`);
  return res.json();
}

// Backend: SELECT * FROM posts ORDER BY created_at DESC LIMIT 20 OFFSET ${page*20}
// User loads page 1 (newest 20 posts), then 5 new posts come in,
// then user loads page 2 — they see the last 5 from page 1 again
```

**Correct (cursor pagination — stable across inserts):**

```ts
type FeedPage = { items: Post[]; nextCursor: string | null };

async function fetchFeedPage(cursor: string | null): Promise<FeedPage> {
  const params = new URLSearchParams({ size: '20' });
  if (cursor) params.set('cursor', cursor);
  const res = await fetch(`/api/feed?${params}`);
  return res.json();
}

// Backend: SELECT * FROM posts WHERE created_at < ${cursor_date} ORDER BY created_at DESC LIMIT 20
// New inserts at the top don't shift the cursor's anchor point
```

**With TanStack Query's useInfiniteQuery:**

```tsx
function Feed() {
  const { data, fetchNextPage, hasNextPage, isFetchingNextPage } = useInfiniteQuery({
    queryKey: ['feed'],
    queryFn: ({ pageParam }) => fetchFeedPage(pageParam),
    initialPageParam: null as string | null,
    getNextPageParam: lastPage => lastPage.nextCursor,
  });

  const allItems = data?.pages.flatMap(p => p.items) ?? [];
  // Items deduplicate cleanly across pages because cursors don't overlap
}
```

**Backend implementation patterns:**

```sql
-- Cursor as a composite: (created_at, id) for tie-breaking
SELECT * FROM posts
WHERE (created_at, id) < ($cursorTime, $cursorId)
ORDER BY created_at DESC, id DESC
LIMIT 21; -- fetch one extra to detect "has next"

-- Encode cursor opaquely so clients can't manipulate it:
-- cursor = base64({ created_at, id })
```

**For real-time feeds (poll the "head" cursor):**

```tsx
// Periodically check for new items above the top — a "newer than cursor X" query
const { data: newItems } = useQuery({
  queryKey: ['feed', 'newer-than', headCursor],
  queryFn: () => fetchNewerThan(headCursor),
  refetchInterval: 30_000,
  enabled: !!headCursor,
});
// Surface as "5 new posts — tap to view" badge instead of inserting mid-scroll
```

**When offset is fine:**
- Stable archives (blog post lists that don't change)
- Admin tables with deterministic sort + low insert rate
- Small data sets where `OFFSET` performance doesn't matter

**Pitfall (don't expose internal DB IDs as cursors):** if your cursor is `?cursor=12345`, users learn that posts are sequential integers and probe gaps. Use opaque, signed cursors.

Reference: [Use The Index, Luke — Pagination](https://use-the-index-luke.com/sql/partial-results/fetch-next-page) | [TanStack Query — Infinite Queries](https://tanstack.com/query/latest/docs/framework/react/guides/infinite-queries)
