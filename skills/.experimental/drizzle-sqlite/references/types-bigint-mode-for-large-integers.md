---
title: Use bigint mode when storing values beyond Number.MAX_SAFE_INTEGER
impact: MEDIUM
impactDescription: prevents silent precision loss
tags: types, bigint, integer, precision
---

## Use bigint mode when storing values beyond Number.MAX_SAFE_INTEGER

JavaScript numbers are 64-bit floats — integers above `2^53 - 1` (`Number.MAX_SAFE_INTEGER`, 9_007_199_254_740_991) lose precision. SQLite happily stores full 64-bit signed integers (`-2^63 .. 2^63 - 1`). The default `integer()` column returns `number`, which silently truncates large values like Snowflake IDs, blockchain block numbers, or unix nanosecond timestamps. `integer({ mode: 'bigint' })` returns a JavaScript `BigInt` instead — keeping full precision at the cost of `bigint` ergonomics (no `+`/`-` with `number`, no JSON serialization by default).

**Incorrect (precision lost on large IDs):**

```typescript
import { sqliteTable, integer, text } from 'drizzle-orm/sqlite-core';

export const tweets = sqliteTable('tweets', {
  // Twitter snowflake IDs are 64-bit:
  id: integer().primaryKey(), // inferred as `number`
  body: text().notNull(),
});

await db.insert(tweets).values({ id: 1729000000000000123, body: '...' });
const [row] = await db.select().from(tweets);
console.log(row.id);
// 1729000000000000000 — last three digits rounded away. Now you can't find this row.
```

**Correct (bigint mode — full 64-bit precision):**

```typescript
import { sqliteTable, integer, text } from 'drizzle-orm/sqlite-core';

export const tweets = sqliteTable('tweets', {
  id: integer({ mode: 'bigint' }).primaryKey(),
  body: text().notNull(),
});

await db.insert(tweets).values({ id: 1729000000000000123n, body: '...' });
const [row] = await db.select().from(tweets);
console.log(row.id);
// 1729000000000000123n — exact.
```

**JSON serialization gotcha:** `JSON.stringify(123n)` throws. Add a serializer or convert at the boundary:

```typescript
// Globally:
declare global {
  interface BigInt { toJSON(): string }
}
BigInt.prototype.toJSON = function () { return this.toString() };

// Or per response (preferred — explicit):
return Response.json({ id: row.id.toString(), body: row.body });
```

**For blob-stored bigints (rare):**

```typescript
// blob({ mode: 'bigint' }) stores the BigInt as raw bytes — useful for u64
// columns where you also want the full unsigned range:
balance: blob({ mode: 'bigint' }).notNull(),
```

**When NOT to use:**
- Auto-incrementing primary keys on tables that won't exceed billions of rows — `integer().primaryKey({ autoIncrement: true })` returning `number` is simpler.
- Counters, page-view tallies, anything genuinely under `2^53`.

**Alternative — store as TEXT:**

For IDs that come from another system (Snowflakes, UUIDs cast to strings), `text().notNull()` and treating the ID as opaque string avoids the bigint serialization tax entirely. Pick text or bigint mode up front; switching later requires a data migration.

Reference: [Drizzle — Integer modes (bigint)](https://orm.drizzle.team/docs/column-types/sqlite#integer) · [MDN — Number.MAX_SAFE_INTEGER](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number/MAX_SAFE_INTEGER)
