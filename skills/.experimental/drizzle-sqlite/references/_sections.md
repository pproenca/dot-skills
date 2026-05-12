# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Schema Definition (schema)

**Impact:** CRITICAL  
**Description:** Column types, primary keys, foreign keys, indexes, and constraints declared in `sqliteTable` are the foundation. SQLite has no native boolean or date types — storing dates as text or booleans as raw integers cascades into every read/write, breaks `orderBy`, and forces conversions in application code. Missing indexes turn every filter into a full table scan; missing primary keys break upserts and replication.

## 2. Migrations & Drizzle Kit (migrate)

**Impact:** CRITICAL  
**Description:** SQLite's `ALTER TABLE` only supports `RENAME`, `ADD COLUMN`, and `DROP COLUMN` — every other change requires a 12-step `CREATE TABLE / INSERT SELECT / DROP / RENAME` dance. `drizzle-kit push` infers schema diffs against a live database and drops columns it cannot reconcile; using it in production destroys data. Column renames look like drop+add to the generator and must be explicitly mapped at prompt time.

## 3. Query Building (query)

**Impact:** HIGH  
**Description:** Wrong builder choice and N+1 patterns dominate runtime latency. `db.select()` without a column object returns every column over the wire; building filters by string concatenation defeats parameter binding; looping `await db.select()` calls inside `for` loops issues one statement per iteration when `inArray()` would issue one.

## 4. Relations (rel)

**Impact:** HIGH  
**Description:** The relational query builder (`db.query.users.findMany({ with: { posts: true } })`) compiles to a single SQL statement with subqueries — manually re-implementing it with `leftJoin` + post-processing usually issues more queries and loses Drizzle's column inference. Relations must be declared in a `relations()` call for `db.query.*` to see them.

## 5. Transactions & Batching (tx)

**Impact:** MEDIUM-HIGH  
**Description:** SQLite is single-writer; any write outside a transaction takes and releases the write lock per statement. Wrapping multi-statement writes in `db.transaction()` amortizes that cost and provides atomicity. For libsql/Turso/D1, `db.batch()` ships multiple statements in one round trip; using it instead of awaited sequential calls eliminates per-statement network latency.

## 6. Prepared Statements & Hot Paths (perf)

**Impact:** MEDIUM-HIGH  
**Description:** Every Drizzle query compiles its builder tree to SQL on each call. For queries that run thousands of times per second (auth lookups, feed fetches), `.prepare()` with `sql.placeholder()` caches the compiled statement; the hot path becomes parameter binding only. Skipping this in tight loops burns CPU on SQL string assembly.

## 7. Connection & Driver Setup (conn)

**Impact:** MEDIUM  
**Description:** SQLite pragmas (`journal_mode=WAL`, `busy_timeout`, `foreign_keys=ON`, `synchronous=NORMAL`) are per-connection and default to write-blocking, FK-off behavior. The Drizzle client must be a singleton — re-instantiating it per request defeats statement caching and can exhaust file handles. Driver choice (better-sqlite3 sync, libsql async, bun:sqlite, D1) constrains which APIs are available.

## 8. Type Inference (types)

**Impact:** MEDIUM  
**Description:** Drizzle infers row shapes from the schema; using those inferred types (`typeof users.$inferSelect`, `InferSelectModel<typeof users>`) keeps API boundaries in sync with the database. Manually written types drift the moment a column is added. For JSON columns, `$type<Shape>()` is the only way to narrow the inferred `unknown`.
