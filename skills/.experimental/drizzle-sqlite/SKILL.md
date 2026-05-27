---
name: drizzle-sqlite
description: Use this skill whenever writing, reviewing, or refactoring Drizzle ORM code targeting SQLite (better-sqlite3, libsql/Turso, bun:sqlite, Cloudflare D1, expo-sqlite, op-sqlite). Covers schema definition (column modes, primary keys, foreign keys, indexes), drizzle-kit migrations (generate vs push, renames, custom SQL), the query builder (selects, upserts, returning, EXPLAIN), the relational query builder (relations(), `with`, partial columns), transactions and `db.batch()`, prepared statements with `sql.placeholder()`, connection pragmas (WAL, foreign_keys, busy_timeout), and Drizzle type inference (`$inferSelect`, `$inferInsert`, `$type<>`, drizzle-zod). Trigger even if the user doesn't say "performance" — schema/migration choices made now are expensive to reverse later, and SQLite-specific traps (single-writer model, no native booleans/dates, ALTER TABLE limits, FK pragma off by default) catch teams who reach for Drizzle without reading the SQLite docs.
---

# dot-skills Drizzle SQLite Best Practices

Library-reference skill for Drizzle ORM with SQLite-family backends. 45 rules across 8 categories, ordered by execution-lifecycle impact: schema → migrations → query → relations → transactions → performance → connection → types.

## When to Apply

Reference these guidelines when:
- Defining `sqliteTable` schemas — choosing column types, primary keys, indexes, foreign keys
- Running `drizzle-kit generate` / `migrate` / `push`, or hand-editing a migration SQL file
- Writing queries with `db.select()`, `db.insert()`, `db.update()`, `db.delete()`
- Reaching for nested data with `db.query.*` and the relational query builder
- Wrapping multi-statement writes in `db.transaction()` or `db.batch()` (libsql/Turso/D1)
- Optimizing a hot-path query with `.prepare()` + `sql.placeholder()` or covering indexes
- Setting up the Drizzle client (pragmas, driver choice, singleton lifecycle)
- Wiring database types into application code (`$inferSelect`, drizzle-zod, JSON shapes)

The skill is not specific to one driver — it covers behavior shared across better-sqlite3, libsql, bun:sqlite, expo-sqlite, op-sqlite, and Cloudflare D1, calling out driver-specific deviations where they exist.

## Architectural Context

SQLite is unusual among production databases:
- **No client/server.** The "connection" is a file open. There is no connection pool, no auth, no network in the local-file case.
- **Single writer.** One writer at a time, no matter how many connections. Reads can be parallel under WAL.
- **No native booleans or dates.** Everything is `INTEGER`, `REAL`, `TEXT`, `BLOB`, or `NULL` — Drizzle column modes encode the rest.
- **Limited `ALTER TABLE`.** Only `RENAME COLUMN`, `ADD COLUMN`, `DROP COLUMN`. Type changes and constraint additions need a table rebuild.
- **Foreign keys off by default.** `PRAGMA foreign_keys = ON` is per-connection and not persistent.

Many rules in this skill exist because Drizzle's API abstracts over PostgreSQL/MySQL/SQLite uniformly — but the underlying SQLite engine has constraints that show up at runtime if you treat it like Postgres.

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Schema Definition | CRITICAL | `schema-` |
| 2 | Migrations & Drizzle Kit | CRITICAL | `migrate-` |
| 3 | Query Building | HIGH | `query-` |
| 4 | Relations | HIGH | `rel-` |
| 5 | Transactions & Batching | MEDIUM-HIGH | `tx-` |
| 6 | Prepared Statements & Hot Paths | MEDIUM-HIGH | `perf-` |
| 7 | Connection & Driver Setup | MEDIUM | `conn-` |
| 8 | Type Inference | MEDIUM | `types-` |

## Quick Reference

### 1. Schema Definition (CRITICAL)

- [`schema-integer-for-booleans`](references/schema-integer-for-booleans.md) — Use `integer({ mode: 'boolean' })` so the inferred type is `boolean`, not `0 | 1`
- [`schema-timestamp-mode-for-dates`](references/schema-timestamp-mode-for-dates.md) — Store dates as `integer({ mode: 'timestamp_ms' })`, not text
- [`schema-always-primary-key`](references/schema-always-primary-key.md) — Declare an explicit PK (single or composite); don't rely on hidden rowid
- [`schema-foreign-keys-with-actions`](references/schema-foreign-keys-with-actions.md) — Specify `onDelete`/`onUpdate` on every `.references()`
- [`schema-index-foreign-keys-and-lookups`](references/schema-index-foreign-keys-and-lookups.md) — Index FK columns and frequent `WHERE`s — SQLite does not auto-index FKs
- [`schema-text-json-not-blob-json`](references/schema-text-json-not-blob-json.md) — Use `text({ mode: 'json' })` so `json_extract` and JSON-path indexes work
- [`schema-unique-constraints-for-natural-keys`](references/schema-unique-constraints-for-natural-keys.md) — `.unique()` for email/slug/externalId so onConflict has a target

### 2. Migrations & Drizzle Kit (CRITICAL)

- [`migrate-generate-not-push-in-prod`](references/migrate-generate-not-push-in-prod.md) — Use `generate + migrate`; `push` drops columns it can't reconcile
- [`migrate-explicit-renames`](references/migrate-explicit-renames.md) — Answer the rename prompt — defaults treat renames as drop+add
- [`migrate-config-dialect-and-out`](references/migrate-config-dialect-and-out.md) — Define `drizzle.config.ts` so commands work without flags
- [`migrate-apply-with-migrator`](references/migrate-apply-with-migrator.md) — Apply via `drizzle-kit migrate` or the driver `migrator` module, not raw SQL
- [`migrate-data-backfill-as-custom-sql`](references/migrate-data-backfill-as-custom-sql.md) — Hand-edit migration SQL to backfill atomically with the DDL
- [`migrate-commit-migrations-to-git`](references/migrate-commit-migrations-to-git.md) — Commit `drizzle/` SQL **and** `drizzle/meta/` snapshots — both are required

### 3. Query Building (HIGH)

- [`query-select-columns-not-star`](references/query-select-columns-not-star.md) — Project to the columns you need with `db.select({ ... })`
- [`query-avoid-n-plus-one-with-inarray`](references/query-avoid-n-plus-one-with-inarray.md) — Replace looped queries with `inArray()`
- [`query-always-limit-listings`](references/query-always-limit-listings.md) — Every listing query needs `.limit()` (and ideally a cursor)
- [`query-bind-parameters-not-concat`](references/query-bind-parameters-not-concat.md) — Use `eq()` / sql template — never string-concat values
- [`query-upsert-with-onconflict`](references/query-upsert-with-onconflict.md) — Atomic upserts via `.onConflictDoUpdate()`, not select-then-write
- [`query-returning-instead-of-reselect`](references/query-returning-instead-of-reselect.md) — `.returning()` on insert/update/delete saves a round trip
- [`query-toSQL-and-explain`](references/query-toSQL-and-explain.md) — Inspect generated SQL and `EXPLAIN QUERY PLAN` on hot paths

### 4. Relations (HIGH)

- [`rel-declare-relations-for-rqb`](references/rel-declare-relations-for-rqb.md) — `relations()` declarations unlock `db.query.*` and `with`
- [`rel-prefer-with-over-manual-joins`](references/rel-prefer-with-over-manual-joins.md) — `with` for nested fetches; manual joins lose typing and add code
- [`rel-partial-columns-in-with`](references/rel-partial-columns-in-with.md) — `columns: { ... }` inside `with` to limit payload and avoid leaks
- [`rel-filter-with-where-inside-with`](references/rel-filter-with-where-inside-with.md) — Push related-row filters into `with.where`, not into JS
- [`rel-leftjoin-for-flat-aggregates`](references/rel-leftjoin-for-flat-aggregates.md) — Drop to `leftJoin` + `groupBy` when you need aggregates

### 5. Transactions & Batching (MEDIUM-HIGH)

- [`tx-wrap-multi-statement-writes`](references/tx-wrap-multi-statement-writes.md) — Wrap related writes in `db.transaction()` for atomicity + throughput
- [`tx-batch-for-libsql-roundtrips`](references/tx-batch-for-libsql-roundtrips.md) — `db.batch()` on libsql/Turso/D1 collapses N round trips into 1
- [`tx-no-network-io-inside-transaction`](references/tx-no-network-io-inside-transaction.md) — No awaited HTTP / FS / Stripe calls inside a transaction
- [`tx-handle-busy-with-retry`](references/tx-handle-busy-with-retry.md) — Bounded retries on `SQLITE_BUSY` — only on transient errors
- [`tx-single-writer-no-parallel-writes`](references/tx-single-writer-no-parallel-writes.md) — `Promise.all` of writes contends; serialize them

### 6. Prepared Statements & Hot Paths (MEDIUM-HIGH)

- [`perf-prepare-hot-paths`](references/perf-prepare-hot-paths.md) — `.prepare()` + `sql.placeholder()` for queries running on every request
- [`perf-bulk-insert-multi-row-values`](references/perf-bulk-insert-multi-row-values.md) — One `values([...rows])` instead of N looped inserts
- [`perf-avoid-count-star-on-large-tables`](references/perf-avoid-count-star-on-large-tables.md) — Counter rows or keyset pagination instead of `count(*)`
- [`perf-keyset-not-offset-for-deep-pages`](references/perf-keyset-not-offset-for-deep-pages.md) — Keyset pagination keeps cost constant across pages
- [`perf-covering-index-for-hot-queries`](references/perf-covering-index-for-hot-queries.md) — Cover the projected columns so the planner skips the row read

### 7. Connection & Driver Setup (MEDIUM)

- [`conn-enable-wal`](references/conn-enable-wal.md) — `journal_mode = WAL` for concurrent reads + one writer
- [`conn-set-busy-timeout`](references/conn-set-busy-timeout.md) — `busy_timeout = 5000` turns contention into a wait
- [`conn-foreign-keys-pragma`](references/conn-foreign-keys-pragma.md) — `foreign_keys = ON` per connection — off by default
- [`conn-singleton-client`](references/conn-singleton-client.md) — Module-scope singleton; never per-request construction
- [`conn-pick-driver-deliberately`](references/conn-pick-driver-deliberately.md) — Sync vs async vs HTTP — choose by deployment target

### 8. Type Inference (MEDIUM)

- [`types-infer-select-insert`](references/types-infer-select-insert.md) — Derive row types with `$inferSelect` / `$inferInsert`
- [`types-narrow-json-with-dollartype`](references/types-narrow-json-with-dollartype.md) — `.$type<Shape>()` to escape `unknown` on JSON columns
- [`types-getTableColumns-for-reuse`](references/types-getTableColumns-for-reuse.md) — Share projections via `getTableColumns()` + spread
- [`types-drizzle-zod-for-runtime-validation`](references/types-drizzle-zod-for-runtime-validation.md) — `createInsertSchema(table)` derives a Zod validator from the schema
- [`types-bigint-mode-for-large-integers`](references/types-bigint-mode-for-large-integers.md) — `mode: 'bigint'` for IDs over `Number.MAX_SAFE_INTEGER`

## How to Use

Read the relevant category overview in `references/_sections.md`, then the specific rule files for detailed explanations and code examples. Each rule has incorrect-vs-correct examples — apply the correct pattern to the code under review.

For complex changes (schema redesign, migration strategy, performance work), read all rules in the affected category before deciding.

- [Section definitions](references/_sections.md) — Category structure and impact levels
- [Rule template](assets/templates/_template.md) — Template for adding new rules

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and reference information |

## Related Skills

- `effect-ts` — When the application is Effect-based; Drizzle integrates via `Effect.tryPromise`.
- `nextjs-bundle-optimizer` — For Next.js apps reaching for SQLite as the data layer.
- `better-auth` — Often paired with Drizzle SQLite for auth tables; see `better-auth-scaffold` for table generation.
