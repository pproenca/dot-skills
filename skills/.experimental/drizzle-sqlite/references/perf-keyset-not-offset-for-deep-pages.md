---
title: Use keyset pagination for deep pages, not OFFSET
impact: MEDIUM-HIGH
impactDescription: O(n) to O(log n) on deep pages
tags: perf, pagination, keyset, offset
---

## Use keyset pagination for deep pages, not OFFSET

`LIMIT 20 OFFSET 10000` doesn't skip 10_000 rows for free — SQLite reads and discards every one of them before returning page 501. Cost grows linearly with offset, so page 1 is fast and page 500 is unusable. Keyset pagination (a.k.a. seek pagination) sorts by an indexed column and uses `WHERE indexed_col < last_seen` to jump straight to the next page. Cost is constant regardless of how far you are.

**Incorrect (OFFSET-based pagination — degrades with depth):**

```typescript
import { desc } from 'drizzle-orm';

async function pagePosts(page: number) {
  return db
    .select()
    .from(posts)
    .orderBy(desc(posts.publishedAt))
    .limit(20)
    .offset(page * 20);
}
// page=500 → SQLite scans 10_000 rows in publishedAt-desc order, then returns 20.
```

**Correct (keyset — constant cost):**

```typescript
import { and, desc, lt, or, eq } from 'drizzle-orm';

type Cursor = { publishedAt: Date; id: number };

async function pagePosts(cursor?: Cursor, pageSize = 20) {
  const rows = await db
    .select()
    .from(posts)
    .where(
      cursor
        ? // Strict tuple comparison: (publishedAt, id) < cursor.
          //   handles ties on publishedAt deterministically.
          or(
            lt(posts.publishedAt, cursor.publishedAt),
            and(eq(posts.publishedAt, cursor.publishedAt), lt(posts.id, cursor.id)),
          )
        : undefined,
    )
    .orderBy(desc(posts.publishedAt), desc(posts.id))
    .limit(pageSize);

  const last = rows[rows.length - 1];
  return {
    rows,
    nextCursor: last ? { publishedAt: last.publishedAt!, id: last.id } : null,
  };
}
```

**Required index — the ORDER BY columns in the same order:**

```typescript
import { index } from 'drizzle-orm/sqlite-core';

(table) => [
  index('posts_published_id_idx').on(desc(table.publishedAt), desc(table.id)),
]
```

**Why the tie-break column matters:** if two posts have the same `publishedAt`, `lt(posts.publishedAt, cursor.publishedAt)` skips both on the next page. Adding `id` as a deterministic tie-breaker prevents duplicates and skips at page boundaries.

**When OFFSET is fine:**
- Shallow paging where users won't go beyond page 10-20 (admin tables, dashboards).
- Total result set is small (< few thousand rows).
- The UI requires "jump to page N" navigation — keyset doesn't support that natively.

Reference: [Use the Index, Luke — No Offset](https://use-the-index-luke.com/no-offset) · [SQLite — Query Planner](https://www.sqlite.org/queryplanner.html)
