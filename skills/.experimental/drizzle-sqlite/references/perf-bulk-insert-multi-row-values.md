---
title: Bulk insert with one multi-row VALUES, not a loop
impact: MEDIUM-HIGH
impactDescription: 10-100x faster than per-row inserts
tags: perf, bulk-insert, batch, values
---

## Bulk insert with one multi-row VALUES, not a loop

`db.insert(table).values([row1, row2, row3, ...])` compiles to a single `INSERT INTO table (...) VALUES (?, ?, ...), (?, ?, ...), (?, ?, ...)`. SQLite parses, plans, and commits it once. Looping `await db.insert(...).values(row)` does all of that per row — even inside a transaction, each statement re-traverses the b-tree to find the insertion point. For a 10K-row import, a multi-row insert finishes in ~100 ms; the loop takes 30+ seconds.

**Incorrect (per-row loop — slow even inside a transaction):**

```typescript
async function importCsv(rows: NewProduct[]) {
  await db.transaction(async (tx) => {
    for (const row of rows) {
      await tx.insert(products).values(row);
    }
  });
}
// 10_000 rows → 10_000 statements parsed and planned individually.
```

**Correct (single multi-row insert):**

```typescript
async function importCsv(rows: NewProduct[]) {
  if (rows.length === 0) return;
  await db.insert(products).values(rows);
}
// One statement, one plan, one commit.
```

**For very large imports — chunk to stay under the parameter limit:**

SQLite's default `SQLITE_MAX_VARIABLE_NUMBER` is 999 in older builds and 32_766 in 3.32+. With 10 columns per row, that's 100 or 3,276 rows per statement.

```typescript
async function importInChunks(rows: NewProduct[], chunkSize = 500) {
  for (let i = 0; i < rows.length; i += chunkSize) {
    const chunk = rows.slice(i, i + chunkSize);
    await db.insert(products).values(chunk);
  }
}
```

**Wrap large imports in a transaction for atomicity + one fsync:**

```typescript
await db.transaction(async (tx) => {
  for (let i = 0; i < rows.length; i += 500) {
    await tx.insert(products).values(rows.slice(i, i + 500));
  }
});
```

Reference: [Drizzle — Insert (multi-row values)](https://orm.drizzle.team/docs/insert#insert-multiple-rows) · [SQLite — Max parameter count](https://www.sqlite.org/limits.html#max_variable_number)
