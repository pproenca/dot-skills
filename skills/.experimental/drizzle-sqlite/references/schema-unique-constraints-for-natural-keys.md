---
title: Add unique constraints for natural keys (email, slug, externalId)
impact: HIGH
impactDescription: prevents race-condition duplicates and unblocks onConflict targets
tags: schema, unique, constraint, integrity
---

## Add unique constraints for natural keys (email, slug, externalId)

Application-level "check then insert" is a TOCTOU race — two concurrent requests both pass the existence check and both insert. The only reliable defense for natural keys (email, username, slug, external provider ID) is a `UNIQUE` constraint in the schema. A unique constraint is also the conflict target `.onConflictDoUpdate({ target: users.email, ... })` needs to act as an idempotent upsert.

**Incorrect (app-level "select then insert" — racy, can produce duplicates):**

```typescript
import { integer, sqliteTable, text } from 'drizzle-orm/sqlite-core';
import { eq } from 'drizzle-orm';

export const users = sqliteTable('users', {
  id: integer().primaryKey({ autoIncrement: true }),
  email: text().notNull(), // No uniqueness
});

async function signUp(email: string) {
  const existing = await db.select().from(users).where(eq(users.email, email));
  if (existing.length > 0) throw new Error('exists');
  await db.insert(users).values({ email }); // Race: two callers can both reach this
}
```

**Correct (unique constraint — database rejects the duplicate atomically):**

```typescript
import { integer, sqliteTable, text } from 'drizzle-orm/sqlite-core';

export const users = sqliteTable('users', {
  id: integer().primaryKey({ autoIncrement: true }),
  email: text().notNull().unique(),
});

async function signUp(email: string) {
  // No select needed — the unique constraint guards uniqueness.
  // .onConflictDoNothing() turns the race into a benign no-op.
  const [user] = await db
    .insert(users)
    .values({ email })
    .onConflictDoNothing({ target: users.email })
    .returning();
  return user; // undefined if email already existed
}
```

**Case-insensitive uniqueness uses `uniqueIndex` on an expression:**

```typescript
import { sql } from 'drizzle-orm';
import { sqliteTable, text, uniqueIndex } from 'drizzle-orm/sqlite-core';

export const users = sqliteTable(
  'users',
  {
    email: text().notNull(),
  },
  (table) => [
    uniqueIndex('users_email_lower_idx').on(sql`lower(${table.email})`),
  ],
);
```

Reference: [Drizzle ORM — Unique constraints](https://orm.drizzle.team/docs/indexes-constraints#unique-constraint)
