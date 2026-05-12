---
title: Set foreign_keys = ON on every connection
impact: HIGH
impactDescription: prevents orphan rows from FKs that look declared
tags: conn, foreign-keys, pragma, integrity
---

## Set foreign_keys = ON on every connection

`PRAGMA foreign_keys` defaults to **OFF** in stock SQLite. The setting is per-connection, not persisted — even after you set it on one connection, the next connection comes up with foreign keys disabled. With it off, `references(() => users.id, { onDelete: 'cascade' })` is purely documentation: parent rows can be deleted without cascading, child rows can reference non-existent parents, and no integrity error is raised. The fix is one pragma call on every connection — and it must happen **outside** any transaction.

**Incorrect (FK declared in schema but never enforced):**

```typescript
import Database from 'better-sqlite3';
import { drizzle } from 'drizzle-orm/better-sqlite3';

const sqlite = new Database('./app.db');
sqlite.pragma('journal_mode = WAL');
// Missing foreign_keys = ON

// schema declares: posts.authorId references users.id ON DELETE CASCADE.
// At runtime: delete a user, posts remain orphaned with authorId pointing nowhere.
```

**Correct (enabled per-connection at construction time):**

```typescript
import Database from 'better-sqlite3';
import { drizzle } from 'drizzle-orm/better-sqlite3';

const sqlite = new Database('./app.db');
sqlite.pragma('journal_mode = WAL');
sqlite.pragma('foreign_keys = ON');
sqlite.pragma('busy_timeout = 5000');
sqlite.pragma('synchronous = NORMAL');
export const db = drizzle(sqlite);
```

**Verify it took:**

```typescript
const [{ enabled }] = await db.all<{ enabled: number }>(sql`PRAGMA foreign_keys`);
console.assert(enabled === 1, 'foreign_keys is off!');
```

**Existing data may already be invalid — check before turning it on:**

If you've been running with FKs off, there could be orphan rows already. Turning enforcement on doesn't retroactively fix them, but it makes subsequent writes that would create new orphans fail. Audit first:

```sql
-- Find orphaned posts:
SELECT id FROM posts WHERE author_id NOT IN (SELECT id FROM users);
```

Fix the rows (delete or repoint), then enable the pragma.

**libsql / Turso:** the libsql client enables foreign keys by default. No pragma needed for the standard configuration.

**Connection-pool implication:** if you create new connections at runtime (e.g., per worker thread), set the pragma in your connection factory, not just at module load. Otherwise pool workers spin up with FKs off.

Reference: [SQLite — PRAGMA foreign_keys](https://www.sqlite.org/pragma.html#pragma_foreign_keys) · [SQLite — Foreign Key Support](https://www.sqlite.org/foreignkeys.html#fk_enable)
