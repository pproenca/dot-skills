---
title: Build covering indexes for hot read queries
impact: MEDIUM-HIGH
impactDescription: eliminates the table row lookup after index probe
tags: perf, index, covering, hot-path
---

## Build covering indexes for hot read queries

A regular index lets SQLite find the matching rowids quickly, but it still needs a second lookup into the table to fetch the selected columns. A **covering** index includes every column the query reads — `WHERE`, `ORDER BY`, **and** the projected columns — so SQLite never touches the table at all. The query plan changes from `SEARCH USING INDEX` + `b-tree lookup` to `SEARCH USING COVERING INDEX`. The win is typically 2-5x on selective queries that return small projections.

**Setup — a hot-path query:**

```typescript
// Called on every page load — "did this user star this post?"
async function isStarred(userId: number, postId: number) {
  const [row] = await db
    .select({ starredAt: stars.starredAt })
    .from(stars)
    .where(and(eq(stars.userId, userId), eq(stars.postId, postId)))
    .limit(1);
  return row?.starredAt ?? null;
}
```

**Incorrect (basic index on just the lookup columns — still hits the table row):**

```typescript
// schema.ts
(table) => [
  index('stars_user_post_idx').on(table.userId, table.postId),
]
```

`EXPLAIN QUERY PLAN`: `SEARCH stars USING INDEX stars_user_post_idx (userId=? AND postId=?)` — then a row read to fetch `starredAt`.

**Correct (covering index includes the projected column):**

```typescript
// schema.ts
(table) => [
  // SQLite uses an index as a covering index when the index contains all
  // referenced columns. Listing `starredAt` as part of the index makes
  // `select starredAt where userId=? and postId=?` index-only.
  index('stars_user_post_starred_idx').on(table.userId, table.postId, table.starredAt),
]
```

`EXPLAIN QUERY PLAN`: `SEARCH stars USING COVERING INDEX stars_user_post_starred_idx (userId=? AND postId=?)` — no row read.

**Trade-offs:**
- Covering indexes consume more disk space — they store the extra columns.
- Writes get slightly slower — every UPDATE that touches a covered column also updates the index.
- For a column that's frequently read but rarely written (like a flag or a timestamp), the math almost always works out.

**Identifying candidates with EXPLAIN QUERY PLAN:**

Look for `USING INDEX` (not `USING COVERING INDEX`) on queries that run thousands of times per minute. Each one is a candidate for promotion to a covering index if the projected columns are small and stable.

**For "is this row present?" existence checks, the index alone is enough — no covering needed:**

```typescript
// Reduces to "does the index entry exist?":
import { sql } from 'drizzle-orm';
const [{ exists }] = await db
  .select({ exists: sql<number>`exists (select 1 from stars where user_id = ${userId} and post_id = ${postId})` })
  .from(sql`(values (1))`); // any single-row source
```

Reference: [SQLite — Covering Indexes](https://www.sqlite.org/queryplanner.html#covidx) · [Drizzle — Indexes](https://orm.drizzle.team/docs/indexes-constraints#indexes)
