---
title: Use db.query `with` for nested fetches, not manual joins + grouping
impact: HIGH
impactDescription: eliminates N+1 queries and manual JS row grouping
tags: rel, with, db-query, joins
---

## Use db.query `with` for nested fetches, not manual joins + grouping

`leftJoin`-then-group-in-JS is the historical pattern: query users joined to posts, get one flat row per (user, post), then bucket them by `user.id` in JavaScript. It's verbose, easy to break (one missing `where` and you double-count), and the inferred type is `(User & { posts: Post })[]` — flat — not what you want. `db.query.users.findMany({ with: { posts: true } })` compiles to a single SQL statement (a correlated subquery or LATERAL join depending on dialect), returns nested `User & { posts: Post[] }`, and stays in sync with relation declarations.

**Incorrect (manual join + JS grouping — verbose, error-prone):**

```typescript
import { eq } from 'drizzle-orm';

async function usersWithPosts() {
  const rows = await db
    .select()
    .from(users)
    .leftJoin(posts, eq(posts.authorId, users.id));

  // rows: { users: User; posts: Post | null }[] — flat, one row per (user, post)
  const grouped = new Map<number, { user: User; posts: Post[] }>();
  for (const row of rows) {
    let bucket = grouped.get(row.users.id);
    if (!bucket) {
      bucket = { user: row.users, posts: [] };
      grouped.set(row.users.id, bucket);
    }
    if (row.posts) bucket.posts.push(row.posts);
  }
  return [...grouped.values()];
}
```

**Correct (relational query — one statement, nested types):**

```typescript
async function usersWithPosts() {
  return db.query.users.findMany({
    with: { posts: true },
  });
  // Inferred: (User & { posts: Post[] })[] — nested, no grouping needed
}
```

**Nested deeper — posts with comments with their authors:**

```typescript
const feed = await db.query.users.findMany({
  with: {
    posts: {
      with: {
        comments: {
          with: { author: { columns: { id: true, name: true } } },
        },
      },
    },
  },
});
```

**When to drop to `leftJoin` instead:**
- You need `GROUP BY` with aggregates (`count`, `sum`, `avg`) across the joined rows.
- You need explicit join control (`INNER`, `FULL OUTER`) for filtering semantics.
- You're projecting a single flat shape (e.g., dashboard table with `user.name` and `post.title` side by side).

For everything else (nested resource trees, has-many fetches), `db.query` is the right tool.

Reference: [Drizzle — Relational Queries with `with`](https://orm.drizzle.team/docs/rqb#combining-relations-on-queries)
