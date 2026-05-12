---
title: Use onConflictDoUpdate/DoNothing for upsert, not select-then-write
impact: HIGH
impactDescription: 1 round trip instead of 2, eliminates TOCTOU races
tags: query, upsert, on-conflict, race-condition
---

## Use onConflictDoUpdate/DoNothing for upsert, not select-then-write

"Try to find the row, update if it exists, insert if it doesn't" implemented as `select` then `insert` or `update` is two round trips and is racy — two callers can both see "not found" and both insert, then one will fail (or you get duplicates if no unique constraint). SQLite supports `INSERT ... ON CONFLICT ... DO UPDATE`, which Drizzle exposes as `.onConflictDoUpdate({ target, set })`. It's one statement, atomic at the database level, and combines naturally with `.returning()`.

**Incorrect (two queries, race window between them):**

```typescript
import { eq } from 'drizzle-orm';

async function recordView(postId: number, userId: number) {
  const [existing] = await db
    .select()
    .from(postViews)
    .where(and(eq(postViews.postId, postId), eq(postViews.userId, userId)));

  if (existing) {
    await db
      .update(postViews)
      .set({ viewedAt: new Date(), count: existing.count + 1 })
      .where(eq(postViews.id, existing.id));
  } else {
    await db.insert(postViews).values({ postId, userId, count: 1, viewedAt: new Date() });
  }
  // Race: two concurrent requests both see existing=null, both insert,
  // unique constraint rejects one.
}
```

**Correct (single atomic statement):**

```typescript
import { sql } from 'drizzle-orm';

async function recordView(postId: number, userId: number) {
  await db
    .insert(postViews)
    .values({ postId, userId, count: 1, viewedAt: new Date() })
    .onConflictDoUpdate({
      target: [postViews.postId, postViews.userId], // unique constraint or PK
      set: {
        count: sql`${postViews.count} + 1`,         // increment server-side
        viewedAt: new Date(),
      },
    });
}
```

**Idempotent insert — "create if missing, otherwise leave it":**

```typescript
const [user] = await db
  .insert(users)
  .values({ email })
  .onConflictDoNothing({ target: users.email })
  .returning(); // returns the new row, or [] if conflict
```

**Conditional update — only overwrite when newer:**

```typescript
import { sql } from 'drizzle-orm';

await db
  .insert(syncState)
  .values({ key, value, version })
  .onConflictDoUpdate({
    target: syncState.key,
    set: { value, version },
    setWhere: sql`${syncState.version} < ${version}`, // skip if local is newer
  });
```

**Requirement:** the conflict target must be a `PRIMARY KEY` or `UNIQUE` constraint/index. Without one, SQLite has nothing to conflict on and the statement falls through to a plain insert.

Reference: [Drizzle — onConflict](https://orm.drizzle.team/docs/insert#on-conflict-do-update) · [SQLite — UPSERT](https://www.sqlite.org/lang_upsert.html)
