---
title: Use inArray for batch lookups instead of looping queries
impact: HIGH
impactDescription: 10-100x latency reduction by eliminating per-row round trips
tags: query, n-plus-one, inarray, batching
---

## Use inArray for batch lookups instead of looping queries

`for (const id of ids) await db.select().from(users).where(eq(users.id, id))` issues one round trip per ID. On a 50-item list against a libsql/Turso remote, that's 50 sequential network calls — easily 2-5 seconds where one query would take 30 ms. `inArray(users.id, ids)` compiles to `WHERE id IN (?, ?, ?, ...)` and returns every match in a single statement. Map the result back to a `Map<id, row>` if you need ordered output.

**Incorrect (N+1 — one query per ID):**

```typescript
import { eq } from 'drizzle-orm';

async function loadUsersByIds(ids: number[]) {
  const result = [];
  for (const id of ids) {
    const [user] = await db.select().from(users).where(eq(users.id, id));
    if (user) result.push(user);
  }
  return result;
}
// 50 ids → 50 round trips. The "await" inside the loop is the bug.
```

**Correct (single query with inArray):**

```typescript
import { inArray } from 'drizzle-orm';

async function loadUsersByIds(ids: number[]) {
  if (ids.length === 0) return [];
  return db.select().from(users).where(inArray(users.id, ids));
}
// 50 ids → 1 round trip.
```

**Preserving caller-supplied order:**

```typescript
async function loadUsersByIds(ids: number[]) {
  if (ids.length === 0) return [];
  const rows = await db.select().from(users).where(inArray(users.id, ids));
  const byId = new Map(rows.map((r) => [r.id, r]));
  return ids.map((id) => byId.get(id)).filter((u) => u !== undefined);
}
```

**Watch out for SQLite's variable limit (default 999, raised to 32_766 in modern SQLite):**

```typescript
// For very large lists, chunk:
async function loadInChunks(ids: number[], chunkSize = 500) {
  const chunks = [];
  for (let i = 0; i < ids.length; i += chunkSize) {
    chunks.push(ids.slice(i, i + chunkSize));
  }
  const results = await Promise.all(
    chunks.map((chunk) => db.select().from(users).where(inArray(users.id, chunk))),
  );
  return results.flat();
}
```

Reference: [Drizzle — inArray operator](https://orm.drizzle.team/docs/operators#inarray)
