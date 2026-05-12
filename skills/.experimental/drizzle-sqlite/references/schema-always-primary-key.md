---
title: Always declare a primary key (single or composite)
impact: CRITICAL
impactDescription: prevents implicit rowid coupling and unblocks upsert/RETURNING
tags: schema, primary-key, rowid, integrity
---

## Always declare a primary key (single or composite)

A SQLite table without a `PRIMARY KEY` still has a hidden `rowid` — but that rowid can be reassigned by `VACUUM`, is not exposed through Drizzle, cannot be referenced by foreign keys, and silently breaks `.onConflictDoUpdate()` because there's no conflict target. Junction tables that look like they have a "compound natural key" need an explicit composite primary key, otherwise the same `(userId, roleId)` pair can be inserted twice.

**Incorrect (no PK on a join table — duplicates and no upsert target):**

```typescript
import { integer, sqliteTable } from 'drizzle-orm/sqlite-core';

export const userRoles = sqliteTable('user_roles', {
  userId: integer().notNull(),
  roleId: integer().notNull(),
});

// Both inserts succeed — table now has two identical rows:
await db.insert(userRoles).values({ userId: 1, roleId: 1 });
await db.insert(userRoles).values({ userId: 1, roleId: 1 });
```

**Correct (composite primary key — duplicates rejected, upsert target available):**

```typescript
import { integer, primaryKey, sqliteTable } from 'drizzle-orm/sqlite-core';

export const userRoles = sqliteTable(
  'user_roles',
  {
    userId: integer().notNull(),
    roleId: integer().notNull(),
  },
  (table) => [
    primaryKey({ columns: [table.userId, table.roleId] }),
  ],
);

await db
  .insert(userRoles)
  .values({ userId: 1, roleId: 1 })
  .onConflictDoNothing(); // second call is a no-op, not a duplicate
```

**For autoincrement single-PK tables, prefer `integer().primaryKey({ autoIncrement: true })` or generate UUIDs/CUIDs in `$defaultFn` rather than relying on rowid.**

Reference: [Drizzle SQLite — primaryKey](https://orm.drizzle.team/docs/indexes-constraints#primary-key)
