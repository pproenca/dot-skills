---
title: Declare relations() so db.query.* can resolve `with`
impact: HIGH
impactDescription: enables single-statement nested fetches via db.query.*
tags: rel, relations, rqb, db-query
---

## Declare relations() so db.query.* can resolve `with`

`db.query.users.findMany({ with: { posts: true } })` only works when Drizzle knows the `users → posts` relationship. That knowledge is declared with the `relations()` helper alongside your table definitions and registered with the `drizzle()` client via the `schema` option. Skip this and `db.query` either won't be typed or will fail at runtime with "no relation found" — and you'll re-implement the join manually for every nested fetch.

**Incorrect (no relations declared — db.query is unusable):**

```typescript
// src/db/schema.ts — tables only, no relations
import { integer, sqliteTable, text } from 'drizzle-orm/sqlite-core';

export const users = sqliteTable('users', {
  id: integer().primaryKey({ autoIncrement: true }),
  email: text().notNull().unique(),
});

export const posts = sqliteTable('posts', {
  id: integer().primaryKey({ autoIncrement: true }),
  authorId: integer().notNull().references(() => users.id, { onDelete: 'cascade' }),
  title: text().notNull(),
});

// src/db/client.ts
import { drizzle } from 'drizzle-orm/better-sqlite3';
import * as schema from './schema';

export const db = drizzle(sqlite, { schema });

// Compile error: Property 'users' does not exist on type 'never'.
const result = await db.query.users.findMany({ with: { posts: true } });
```

**Correct (relations declared + registered):**

```typescript
// src/db/schema.ts
import { relations } from 'drizzle-orm';
import { integer, sqliteTable, text } from 'drizzle-orm/sqlite-core';

export const users = sqliteTable('users', {
  id: integer().primaryKey({ autoIncrement: true }),
  email: text().notNull().unique(),
});

export const posts = sqliteTable('posts', {
  id: integer().primaryKey({ autoIncrement: true }),
  authorId: integer().notNull().references(() => users.id, { onDelete: 'cascade' }),
  title: text().notNull(),
});

export const usersRelations = relations(users, ({ many }) => ({
  posts: many(posts),
}));

export const postsRelations = relations(posts, ({ one }) => ({
  author: one(users, { fields: [posts.authorId], references: [users.id] }),
}));
```

```typescript
// src/db/client.ts — register the schema (tables AND relations)
import { drizzle } from 'drizzle-orm/better-sqlite3';
import * as schema from './schema';

export const db = drizzle(sqlite, { schema });
// Now db.query.users and db.query.posts are typed and `with` resolves:
const result = await db.query.users.findMany({ with: { posts: true } });
```

**Naming the FK relation when there are two:**

If a table has two FKs to the same parent (e.g., `messages.fromUserId` and `messages.toUserId`), name the relations so Drizzle can disambiguate:

```typescript
export const messages = sqliteTable('messages', {
  id: integer().primaryKey(),
  fromUserId: integer().notNull().references(() => users.id),
  toUserId: integer().notNull().references(() => users.id),
});

export const messagesRelations = relations(messages, ({ one }) => ({
  from: one(users, { fields: [messages.fromUserId], references: [users.id], relationName: 'sent' }),
  to:   one(users, { fields: [messages.toUserId],   references: [users.id], relationName: 'received' }),
}));

export const usersRelations = relations(users, ({ many }) => ({
  sent:     many(messages, { relationName: 'sent' }),
  received: many(messages, { relationName: 'received' }),
}));
```

Reference: [Drizzle — Relations](https://orm.drizzle.team/docs/relations) · [Drizzle — Relational Queries](https://orm.drizzle.team/docs/rqb)
