---
title: Drop to leftJoin when you need aggregates or flat shapes
impact: MEDIUM-HIGH
impactDescription: prevents O(n) JS-side aggregation over hydrated rows
tags: rel, leftjoin, aggregate, group-by
---

## Drop to leftJoin when you need aggregates or flat shapes

`db.query.*` returns nested resources. When the output is one flat row per parent with aggregates over the children — "users with their post count and last-post-date" — `leftJoin` + `groupBy` is the right tool. Trying to express this in the relational query builder either doesn't compose (no aggregate over a `with` collection) or produces a less efficient plan than a direct `GROUP BY`. Use `leftJoin` so users with zero posts still appear (`innerJoin` drops them), and project explicit `count()` / `max()` expressions.

**Incorrect (load all posts into JS, then aggregate — slow and memory-bound):**

```typescript
const users = await db.query.users.findMany({
  with: { posts: true },
});

const summary = users.map((u) => ({
  userId: u.id,
  name: u.name,
  postCount: u.posts.length,
  lastPostAt: u.posts.reduce<Date | null>(
    (max, p) => (!max || p.publishedAt! > max ? p.publishedAt : max),
    null,
  ),
}));
// Loaded every column of every post just to count and find the max.
```

**Correct (SQL aggregate — one statement, server-side counts):**

```typescript
import { count, eq, max } from 'drizzle-orm';

const summary = await db
  .select({
    userId: users.id,
    name: users.name,
    postCount: count(posts.id), // count of non-null = posts joined
    lastPostAt: max(posts.publishedAt),
  })
  .from(users)
  .leftJoin(posts, eq(posts.authorId, users.id))
  .groupBy(users.id, users.name);
```

**Why `leftJoin` and not `innerJoin`:**
`innerJoin` drops users with zero posts. `leftJoin` keeps them with `postCount = 0` and `lastPostAt = null` — usually the correct shape for a dashboard.

**Combine with a `having` for filtered aggregates ("users with ≥ 5 posts"):**

```typescript
import { count, eq, gte } from 'drizzle-orm';

const prolific = await db
  .select({ userId: users.id, name: users.name, postCount: count(posts.id) })
  .from(users)
  .leftJoin(posts, eq(posts.authorId, users.id))
  .groupBy(users.id, users.name)
  .having(({ postCount }) => gte(postCount, 5));
```

**Window function alternative — when you need the aggregate alongside the raw rows:**

For "every post with its author's total post count", a window function avoids the GROUP BY altogether:

```typescript
import { sql, eq } from 'drizzle-orm';

const rows = await db
  .select({
    postId: posts.id,
    title: posts.title,
    authorPostCount: sql<number>`count(*) over (partition by ${posts.authorId})`,
  })
  .from(posts);
```

Reference: [Drizzle — Aggregations & GROUP BY](https://orm.drizzle.team/docs/select#aggregations-helpers) · [Drizzle — Joins](https://orm.drizzle.team/docs/joins)
