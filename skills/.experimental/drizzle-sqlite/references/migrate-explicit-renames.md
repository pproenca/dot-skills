---
title: Answer rename prompts explicitly to preserve column data
impact: CRITICAL
impactDescription: prevents drop+add destroying renamed column data
tags: migrate, rename, drizzle-kit, data-loss
---

## Answer rename prompts explicitly to preserve column data

When you rename a column or table in `schema.ts`, `drizzle-kit generate` cannot tell whether you intended `RENAME COLUMN` or `DROP old + ADD new`. It prompts interactively: `Is column users.userId renamed to ownerId? (Y/n)`. Hitting enter or running with `--yes` blindly accepts drop+add — and SQLite's `ALTER TABLE ... DROP COLUMN` permanently deletes the data. Always run `generate` interactively for schema changes that touch existing tables and answer the rename prompt explicitly.

**Incorrect (CI-style non-interactive generate after a rename — data lost):**

```bash
# schema.ts: column `user_id` was renamed to `owner_id`
yes "" | npx drizzle-kit generate
# Defaults answer rename prompts as "no" → generated SQL is:
#   ALTER TABLE posts DROP COLUMN user_id;
#   ALTER TABLE posts ADD COLUMN owner_id INTEGER NOT NULL;
# Every existing row now has NULL owner_id (or fails NOT NULL).
```

**Correct (interactive — confirm the rename so it becomes ALTER ... RENAME):**

```bash
npx drizzle-kit generate
# ? Is column posts.user_id renamed to owner_id? (y/n) y
# Generated SQL: ALTER TABLE posts RENAME COLUMN user_id TO owner_id;
# Existing data preserved.
```

**For changes the generator can't represent (type changes, complex restructures), hand-edit:**

SQLite's `ALTER TABLE` cannot change a column type or drop NOT NULL. Hand-edit the generated migration using the [12-step recipe](https://www.sqlite.org/lang_altertable.html#otheralter):

```sql
-- ./drizzle/0008_change_posts_id_type.sql
PRAGMA foreign_keys = OFF;

CREATE TABLE posts_new (
  id TEXT PRIMARY KEY,            -- changed from INTEGER
  owner_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  body TEXT NOT NULL
);

INSERT INTO posts_new (id, owner_id, body)
  SELECT CAST(id AS TEXT), owner_id, body FROM posts;

DROP TABLE posts;
ALTER TABLE posts_new RENAME TO posts;

PRAGMA foreign_keys = ON;
```

**Always:**
- Wrap data-migrating SQL in a transaction (`drizzle-kit migrate` does this automatically per file).
- Test the migration against a copy of production before merging.

Reference: [Drizzle Kit — handling renames](https://orm.drizzle.team/docs/drizzle-kit-generate) · [SQLite — Making other kinds of table schema changes](https://www.sqlite.org/lang_altertable.html#otheralter)
