---
title: Store dates as integer timestamp_ms, not text
impact: CRITICAL
impactDescription: enables index-backed range queries and prevents ISO string drift
tags: schema, dates, timestamp, sqlite-types
---

## Store dates as integer timestamp_ms, not text

SQLite has no native date type. Storing dates as ISO strings means `orderBy(createdAt)` becomes lexicographic — it works only if every value is normalized to the same zero-padded `YYYY-MM-DDTHH:MM:SS.sssZ` form, and one stray timezone offset breaks ordering silently. `integer({ mode: 'timestamp_ms' })` stores epoch milliseconds, gives you integer-comparison range queries, indexes correctly, and Drizzle returns `Date` objects on read. Use `timestamp` mode (seconds) only for compatibility with existing schemas.

**Incorrect (text dates — lexicographic ordering, no type safety):**

```typescript
import { sqliteTable, text } from 'drizzle-orm/sqlite-core';

export const events = sqliteTable('events', {
  id: text().primaryKey(),
  occurredAt: text().notNull(), // 'is it ISO? local? unix string?'
});

// Caller must remember to call toISOString and worry about TZ:
await db.insert(events).values({ id, occurredAt: new Date().toISOString() });
```

**Correct (integer timestamp_ms — indexable, type-safe):**

```typescript
import { integer, sqliteTable, text } from 'drizzle-orm/sqlite-core';
import { sql } from 'drizzle-orm';

export const events = sqliteTable('events', {
  id: text().primaryKey(),
  occurredAt: integer({ mode: 'timestamp_ms' })
    .notNull()
    .$defaultFn(() => new Date()),
});

await db.insert(events).values({ id }); // $defaultFn fills occurredAt
const recent = await db
  .select()
  .from(events)
  .where(sql`${events.occurredAt} > ${Date.now() - 86_400_000}`)
  .orderBy(events.occurredAt);
```

**When NOT to use:**
- The column must be human-readable in raw SQLite browsers and you've already paid the cost of strict ISO discipline.
- You're consuming a legacy schema you don't own (use `mode: 'timestamp'` to map seconds-since-epoch if that's the existing format).

Reference: [Drizzle SQLite Column Types — Integer modes](https://orm.drizzle.team/docs/column-types/sqlite#integer)
