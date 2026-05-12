---
title: Declare foreign keys with explicit onDelete/onUpdate
impact: CRITICAL
impactDescription: prevents orphaned rows and undefined cascade behavior
tags: schema, foreign-key, references, cascade
---

## Declare foreign keys with explicit onDelete/onUpdate

A `references(() => parent.id)` without `onDelete` defaults to SQLite's `NO ACTION` — and only if `PRAGMA foreign_keys = ON` is set on the connection (it is **off by default** in SQLite). The combination means rows in the parent can be deleted while the child still references them, leaving orphaned IDs that fail any subsequent join. Always specify the cascade behavior explicitly so the intent is in the schema, not in application code.

**Incorrect (no onDelete — orphans on parent delete if FK ever enforced):**

```typescript
import { integer, sqliteTable, text } from 'drizzle-orm/sqlite-core';

export const users = sqliteTable('users', {
  id: integer().primaryKey({ autoIncrement: true }),
});

export const posts = sqliteTable('posts', {
  id: integer().primaryKey({ autoIncrement: true }),
  authorId: integer()
    .notNull()
    .references(() => users.id), // No cascade specified
  body: text().notNull(),
});
```

**Correct (explicit cascade — intent recorded in schema):**

```typescript
import { integer, sqliteTable, text } from 'drizzle-orm/sqlite-core';

export const users = sqliteTable('users', {
  id: integer().primaryKey({ autoIncrement: true }),
});

export const posts = sqliteTable('posts', {
  id: integer().primaryKey({ autoIncrement: true }),
  authorId: integer()
    .notNull()
    .references(() => users.id, { onDelete: 'cascade', onUpdate: 'cascade' }),
  body: text().notNull(),
});
```

**Alternative (soft-delete style — keep the row but allow detach):**

```typescript
authorId: integer().references(() => users.id, { onDelete: 'set null' }),
```

**Cascade choice cheat sheet:**
- `'cascade'` — child rows are deleted with the parent (comments under a deleted post)
- `'set null'` — child keeps row but loses link (orders detach from a deleted customer)
- `'restrict'` — block parent delete if children exist (categories with active products)

**Foreign keys are only enforced when the connection has `PRAGMA foreign_keys = ON` set — see [conn-foreign-keys-pragma](conn-foreign-keys-pragma.md).**

Reference: [Drizzle ORM — Foreign Keys](https://orm.drizzle.team/docs/indexes-constraints#foreign-key)
