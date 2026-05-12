---
title: Use text mode 'json' for JSON columns, not blob
impact: HIGH
impactDescription: enables json_extract and indexes on JSON fields
tags: schema, json, sqlite-types, blob
---

## Use text mode 'json' for JSON columns, not blob

Both `blob({ mode: 'json' })` and `text({ mode: 'json' })` store JSON, but SQLite's built-in `json1` extension (`json_extract`, `json_each`, `->`, `->>`) only operates on **text** values. A blob-stored JSON column can be read back as a typed object but cannot participate in `WHERE json_extract(data, '$.role') = 'admin'`, indexed JSON paths, or `json_patch` updates — you must hydrate every row to filter. Use `text({ mode: 'json' })` unless you have a specific reason (binary payload, JSONB future-compat) to store opaque bytes.

**Incorrect (blob JSON — cannot query inside the document):**

```typescript
import { blob, integer, sqliteTable } from 'drizzle-orm/sqlite-core';

type Settings = { theme: 'light' | 'dark'; notifications: boolean };

export const userPrefs = sqliteTable('user_prefs', {
  userId: integer().primaryKey(),
  settings: blob({ mode: 'json' }).$type<Settings>().notNull(),
});

// To find dark-mode users, you must load all rows and filter in JS:
const all = await db.select().from(userPrefs);
const darkUsers = all.filter((r) => r.settings.theme === 'dark');
```

**Correct (text JSON — server-side filtering, indexable paths):**

```typescript
import { integer, sqliteTable, text } from 'drizzle-orm/sqlite-core';
import { sql } from 'drizzle-orm';

type Settings = { theme: 'light' | 'dark'; notifications: boolean };

export const userPrefs = sqliteTable('user_prefs', {
  userId: integer().primaryKey(),
  settings: text({ mode: 'json' }).$type<Settings>().notNull(),
});

// Filter inside the JSON document:
const darkUsers = await db
  .select()
  .from(userPrefs)
  .where(sql`json_extract(${userPrefs.settings}, '$.theme') = 'dark'`);
```

**Index a JSON path (SQLite ≥ 3.38):**

```sql
CREATE INDEX user_prefs_theme_idx
  ON user_prefs (json_extract(settings, '$.theme'));
```

Then `WHERE json_extract(settings, '$.theme') = 'dark'` uses the index instead of scanning.

**When NOT to use:**
- You're storing opaque binary payloads (encrypted blobs, protobuf) — `blob({ mode: 'buffer' })` is correct.

Reference: [SQLite — JSON1 functions](https://www.sqlite.org/json1.html) · [Drizzle — text/blob JSON modes](https://orm.drizzle.team/docs/column-types/sqlite#text)
