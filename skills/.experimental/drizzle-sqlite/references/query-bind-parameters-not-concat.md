---
title: Bind parameters with eq/sql tagged template — never concatenate
impact: HIGH
impactDescription: prevents SQL injection and re-enables query plan caching
tags: query, sql-injection, sql-template, parameters
---

## Bind parameters with eq/sql tagged template — never concatenate

Drizzle's operators (`eq`, `inArray`, `gt`, etc.) and the `sql` tagged template both produce parameterized SQL — values are sent separately from the query string and bound by the driver. Building SQL with regular string concatenation (or worse, `sql.raw(...)` with user input) re-introduces SQL injection and defeats SQLite's prepared-statement cache (every distinct concatenated query is a fresh compile). The `sql` template's `${}` interpolations are bound parameters by default; only `sql.raw` injects unescaped text.

**Incorrect (string concat — injectable AND defeats statement cache):**

```typescript
import { sql } from 'drizzle-orm';

async function search(term: string) {
  // ❌ Direct injection via ${term} as raw string
  return db.all(sql.raw(`SELECT id, name FROM users WHERE name LIKE '%${term}%'`));
  // term = "x'; DELETE FROM users; --" → game over.
}
```

**Correct (sql template — parameters bound, cache shared across calls):**

```typescript
import { sql } from 'drizzle-orm';

async function search(term: string) {
  // ${term} is a bound parameter, not concatenated text.
  return db.all<{ id: number; name: string }>(
    sql`SELECT id, name FROM users WHERE name LIKE ${'%' + term + '%'}`,
  );
}
```

**Correct (operator form — type-safe, idiomatic):**

```typescript
import { like } from 'drizzle-orm';

async function search(term: string) {
  return db
    .select({ id: users.id, name: users.name })
    .from(users)
    .where(like(users.name, `%${term}%`));
}
```

**When you actually need dynamic SQL identifiers (table/column names):**

`sql.identifier()` quotes them safely; never use `sql.raw` on user input.

```typescript
import { sql } from 'drizzle-orm';

const orderColumn = req.query.sort === 'name' ? 'name' : 'created_at';
const rows = await db.all(
  sql`SELECT id, name FROM users ORDER BY ${sql.identifier(orderColumn)} DESC LIMIT 50`,
);
```

**Never pass raw user input to `sql.identifier()`** — always whitelist first (the ternary above does this). Identifiers are not parameters; they're inlined as quoted SQL names.

Reference: [Drizzle — `sql` template](https://orm.drizzle.team/docs/sql) · [SQLite — Prepared statement caching](https://www.sqlite.org/c3ref/prepare.html)
