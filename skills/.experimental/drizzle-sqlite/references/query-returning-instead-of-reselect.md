---
title: Use .returning() instead of a second SELECT after write
impact: MEDIUM-HIGH
impactDescription: eliminates a 2nd select round trip per write
tags: query, returning, insert, update, delete
---

## Use .returning() instead of a second SELECT after write

After `db.insert(...).values(...)`, callers often need the inserted row — the generated ID, the `$defaultFn` slug, the `created_at` timestamp. Doing that with a second `db.select().where(eq(users.email, email))` is two round trips and a logical race (another writer could update the row between the insert and the select). SQLite supports `INSERT ... RETURNING`, `UPDATE ... RETURNING`, and `DELETE ... RETURNING` since 3.35, and Drizzle exposes all three via `.returning()`. One round trip, atomic, no race.

**Incorrect (insert + re-select — two round trips, race window):**

```typescript
import { eq } from 'drizzle-orm';

async function createUser(email: string) {
  await db.insert(users).values({ email });
  const [user] = await db.select().from(users).where(eq(users.email, email));
  return user;
}
```

**Correct (returning — one statement):**

```typescript
async function createUser(email: string) {
  const [user] = await db.insert(users).values({ email }).returning();
  return user;
}
```

**Partial returning — only what you need:**

```typescript
const [{ id }] = await db
  .insert(users)
  .values({ email })
  .returning({ id: users.id });
```

**Works on update/delete too:**

```typescript
// Audit trail — return the old row by capturing its values via update + returning:
const [updated] = await db
  .update(users)
  .set({ status: 'deactivated' })
  .where(eq(users.id, userId))
  .returning();

// Returning from delete — useful for soft-delete + audit:
const [deleted] = await db
  .delete(sessions)
  .where(eq(sessions.token, token))
  .returning({ userId: sessions.userId });
```

**Driver support note:** `.returning()` works on better-sqlite3, libsql/Turso, bun:sqlite, and op-sqlite. On Cloudflare D1 it works for single-statement writes but not inside `db.batch()` — check the response shape.

Reference: [Drizzle — Insert with returning](https://orm.drizzle.team/docs/insert#insert-returning) · [SQLite 3.35 — RETURNING](https://www.sqlite.org/lang_returning.html)
