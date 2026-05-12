---
title: Use columns inside `with` to keep nested payloads small
impact: HIGH
impactDescription: 2-5x payload reduction on nested fetches
tags: rel, partial, columns, payload
---

## Use columns inside `with` to keep nested payloads small

`with: { posts: true }` returns every column of every related post. For a "user header + recent post titles" UI, that's loading every post body, every metadata blob, every analytics column — over and over for every user in the result set. The `columns:` selector inside `with` projects the related rows to the columns you actually need; combine it with `limit` to cap how many related rows come back per parent.

**Incorrect (with: true loads every post column for every user):**

```typescript
const usersWithPosts = await db.query.users.findMany({
  columns: { id: true, name: true },
  with: {
    posts: true, // Every column of every post per user — huge payload
  },
});
```

**Correct (columns + limit — bounded fetch):**

```typescript
const usersWithPosts = await db.query.users.findMany({
  columns: { id: true, name: true },
  with: {
    posts: {
      columns: { id: true, title: true, publishedAt: true },
      limit: 5,
      orderBy: (p, { desc }) => desc(p.publishedAt),
    },
  },
});
```

**Excluding columns instead of including them — useful when most columns are wanted:**

```typescript
const post = await db.query.posts.findFirst({
  where: (p, { eq }) => eq(p.id, postId),
  columns: { internalAnalyticsBlob: false }, // every other column included
  with: {
    author: { columns: { id: true, name: true, avatarUrl: true } },
    // ↑ Don't leak email/password_hash by selecting * on the author
  },
});
```

**Security implication:** the `columns:` selector on `author` above isn't just a payload optimization — it's an authorization decision. Selecting `password_hash` or `email_verification_token` because you used `with: { author: true }` and then forgot to redact in the response is a real bug pattern. Project to the fields callers should see.

Reference: [Drizzle — Partial fields on relational queries](https://orm.drizzle.team/docs/rqb#select-filters)
