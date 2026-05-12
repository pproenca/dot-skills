---
title: Filter related rows in `with`'s where, not in JavaScript
impact: HIGH
impactDescription: 2-10x payload reduction on filtered nested fetches
tags: rel, with, where, filtering
---

## Filter related rows in `with`'s where, not in JavaScript

`with: { posts: true }` returns every related post; calling `.posts.filter((p) => p.published)` in JavaScript means the unpublished draft posts still travelled over the wire and were deserialized. The `where:` clause inside `with` pushes the filter into the SQL subquery — only matching rows leave the database. Combine with `limit`, `offset`, and `orderBy` to fully express the related-fetch on the server.

**Incorrect (filter in JS after the fetch — wasted bandwidth and CPU):**

```typescript
const users = await db.query.users.findMany({
  with: { posts: true },
});

// Drafts and archived posts came across the wire only to be discarded:
const usersWithPublishedPosts = users.map((u) => ({
  ...u,
  posts: u.posts.filter((p) => p.published),
}));
```

**Correct (where: inside with — filter at the source):**

```typescript
const users = await db.query.users.findMany({
  with: {
    posts: {
      where: (p, { eq, and, isNotNull }) =>
        and(eq(p.published, true), isNotNull(p.publishedAt)),
      orderBy: (p, { desc }) => desc(p.publishedAt),
      limit: 10,
    },
  },
});
```

**Complex per-row filters use the second-arg helpers (`eq`, `and`, `or`, `not`, `inArray`, `gt`, etc.):**

```typescript
const usersWithRecentActivity = await db.query.users.findMany({
  where: (u, { eq }) => eq(u.status, 'active'),
  with: {
    posts: {
      where: (p, { and, gt, eq }) =>
        and(
          eq(p.published, true),
          gt(p.publishedAt, new Date(Date.now() - 7 * 86_400_000)),
        ),
    },
  },
});
```

**Parent-side filter that depends on related rows — `where` + `exists` on the parent:**

If you want "users that have at least one published post", filter on the parent with a subquery rather than expecting `with` to drop empty parents:

```typescript
import { exists, eq, and } from 'drizzle-orm';

const authors = await db
  .select()
  .from(users)
  .where(
    exists(
      db.select({ one: sql`1` })
        .from(posts)
        .where(and(eq(posts.authorId, users.id), eq(posts.published, true))),
    ),
  );
```

`with: { posts: { where: ... } }` does **not** filter out parents that have zero matching related rows — they come back with `posts: []`. That's the expected behavior; use the `exists` pattern above when you need parent-side filtering.

Reference: [Drizzle — Filters on relational queries](https://orm.drizzle.team/docs/rqb#select-filters)
