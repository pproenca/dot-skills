---
title: Edit migration SQL to backfill data atomically with DDL
impact: HIGH
impactDescription: prevents NULL/inconsistent rows between deploy and worker run
tags: migrate, backfill, custom-sql, atomicity
---

## Edit migration SQL to backfill data atomically with DDL

A migration that adds a `NOT NULL` column needs default values for existing rows. Doing that in application code after deploy means there's a window where the column is NULL and reads fail — or worse, you forget and the migration silently leaves rows in a broken state. The generated SQL file is just a text file; open it and append the `UPDATE` so schema change and backfill commit together. `drizzle-kit migrate` runs each file in a transaction, so the backfill rolls back with the DDL if anything fails.

**Incorrect (app-code backfill — leaves rows broken between deploy and worker run):**

```sql
-- ./drizzle/0009_add_post_slug.sql (generated, untouched)
ALTER TABLE posts ADD COLUMN slug TEXT NOT NULL DEFAULT '';
```

```typescript
// Then in a separate "backfill worker" deployed later:
const all = await db.select().from(posts);
for (const post of all) {
  await db.update(posts).set({ slug: slugify(post.title) }).where(eq(posts.id, post.id));
}
// Until this runs, every post has slug = '' — including new ones if you forget to wire the default.
```

**Correct (backfill inline, atomic with the DDL):**

```sql
-- ./drizzle/0009_add_post_slug.sql (hand-edited after generate)
ALTER TABLE posts ADD COLUMN slug TEXT;

UPDATE posts
   SET slug = lower(replace(replace(title, ' ', '-'), '.', ''))
 WHERE slug IS NULL;

-- For backfills SQLite can't express, prefer a two-migration pattern:
-- 0009 adds nullable column + backfills, 0010 adds NOT NULL constraint.
-- (See note below — SQLite cannot add NOT NULL via ALTER, so 0010 is a table rebuild.)
```

**Two-step pattern when backfill must run in application code (e.g., crypto, external API lookup):**

```sql
-- 0009_add_external_id_nullable.sql
ALTER TABLE users ADD COLUMN external_id TEXT;
CREATE INDEX users_external_id_idx ON users(external_id);
```

Deploy app code that double-writes `external_id` on every signup, then a one-off backfill job. Once `external_id IS NULL` count is zero:

```sql
-- 0010_external_id_not_null.sql — table rebuild because SQLite cannot add NOT NULL
PRAGMA foreign_keys = OFF;
CREATE TABLE users_new (...same schema with NOT NULL...);
INSERT INTO users_new SELECT * FROM users;
DROP TABLE users;
ALTER TABLE users_new RENAME TO users;
PRAGMA foreign_keys = ON;
```

**Breakpoints:** `drizzle-kit` inserts `--> statement-breakpoint` markers so the migrator runs each statement separately when the driver requires it (D1, some libsql configs). Don't remove them.

Reference: [Drizzle — Custom migrations](https://orm.drizzle.team/docs/drizzle-kit-generate#custom-migrations) · [SQLite — ALTER TABLE limitations](https://www.sqlite.org/lang_altertable.html)
