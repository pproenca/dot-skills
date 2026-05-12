---
title: Use integer mode 'boolean' for boolean columns
impact: CRITICAL
impactDescription: prevents 0/1 leaking into application types
tags: schema, types, boolean, sqlite-types
---

## Use integer mode 'boolean' for boolean columns

SQLite has no native boolean type — it stores everything as `INTEGER`, `REAL`, `TEXT`, `BLOB`, or `NULL`. A raw `integer()` column lets `0` and `1` leak into application code as `number`, forcing every consumer to remember the encoding and breaking `=== true` / `=== false` checks. Declaring `integer({ mode: 'boolean' })` tells Drizzle to convert at the driver boundary so the inferred TypeScript type is `boolean`.

**Incorrect (raw integer leaks `0 | 1` into the app):**

```typescript
import { integer, sqliteTable, text } from 'drizzle-orm/sqlite-core';

export const users = sqliteTable('users', {
  id: integer().primaryKey(),
  email: text().notNull(),
  emailVerified: integer().notNull().default(0), // inferred as number — 0/1
});

const [user] = await db.select().from(users).limit(1);
if (user.emailVerified === true) { /* unreachable — value is 0 or 1 */ }
```

**Correct (boolean mode — Drizzle converts at the boundary):**

```typescript
import { integer, sqliteTable, text } from 'drizzle-orm/sqlite-core';

export const users = sqliteTable('users', {
  id: integer().primaryKey(),
  email: text().notNull(),
  emailVerified: integer({ mode: 'boolean' }).notNull().default(false),
});

const [user] = await db.select().from(users).limit(1);
if (user.emailVerified) { /* works — value is true | false */ }
```

**When NOT to use:**
- The column genuinely represents a tri-state (`0`, `1`, `2`) or a small integer enum encoded as numbers. In that case `integer()` with a check constraint is correct.
- You're consuming an existing schema that already stores something other than `0`/`1` (e.g., `'Y'`/`'N'` text). Map to the existing storage type rather than coercing.

Reference: [Drizzle SQLite Column Types — Boolean](https://orm.drizzle.team/docs/column-types/sqlite#boolean)
