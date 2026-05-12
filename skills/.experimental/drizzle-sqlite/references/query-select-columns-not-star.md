---
title: Select only the columns you need
impact: HIGH
impactDescription: 2-10x payload reduction on wide tables
tags: query, select, projection, bandwidth
---

## Select only the columns you need

`db.select().from(users)` is `SELECT * FROM users` — every column over the wire, including the 50 KB `bio` text and the JSON `preferences` blob, even when the UI just needs `id` and `name`. Drizzle's column-object form `db.select({ id: users.id, name: users.name })` projects to exactly the columns you list; the result type narrows accordingly. The savings compound on libsql/Turso (network bytes), on serverless databases (egress cost), and on hot paths (deserialization time).

**Incorrect (select * — every column, every row):**

```typescript
import { eq } from 'drizzle-orm';

// Authentication endpoint, called on every request:
const [user] = await db
  .select() // → SELECT id, email, password_hash, name, bio, avatar_url, preferences, created_at, updated_at FROM users
  .from(users)
  .where(eq(users.id, userId));

if (user) {
  return { id: user.id, name: user.name }; // 90% of the row never used
}
```

**Correct (projection — narrow query, narrow type):**

```typescript
import { eq } from 'drizzle-orm';

const [user] = await db
  .select({ id: users.id, name: users.name })
  .from(users)
  .where(eq(users.id, userId));
// Inferred type: { id: number; name: string } | undefined
```

**Tip — for `db.query.*` (relational queries), use `columns: { ... }`:**

```typescript
const post = await db.query.posts.findFirst({
  where: (p, { eq }) => eq(p.id, postId),
  columns: { id: true, title: true, publishedAt: true },
});
```

**When NOT to use:**
- You genuinely need every column (e.g., serializing the row for an export). In that case, `db.select().from()` is correct — the readability cost of listing 30 columns isn't worth it.

Reference: [Drizzle — Select queries](https://orm.drizzle.team/docs/select#partial-select)
