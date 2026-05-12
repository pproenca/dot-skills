# Drizzle ORM + SQLite

**Version 0.1.0**  
dot-skills  
May 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Library-reference skill for Drizzle ORM with SQLite-family backends (better-sqlite3, libsql/Turso, bun:sqlite, Cloudflare D1, expo-sqlite, op-sqlite). Contains 45 rules across 8 categories ordered by execution-lifecycle impact — from CRITICAL schema and migration decisions to MEDIUM type-inference patterns. Each rule pairs an incorrect/correct example with a quantified impact and links to authoritative Drizzle, SQLite, and driver documentation.

---

## Table of Contents

1. [Schema Definition](references/_sections.md#1-schema-definition) — **CRITICAL**
   - 1.1 [Add unique constraints for natural keys (email, slug, externalId)](references/schema-unique-constraints-for-natural-keys.md) — HIGH (prevents race-condition duplicates and unblocks onConflict targets)
   - 1.2 [Always declare a primary key (single or composite)](references/schema-always-primary-key.md) — CRITICAL (prevents implicit rowid coupling and unblocks upsert/RETURNING)
   - 1.3 [Declare foreign keys with explicit onDelete/onUpdate](references/schema-foreign-keys-with-actions.md) — CRITICAL (prevents orphaned rows and undefined cascade behavior)
   - 1.4 [Index foreign keys and frequent WHERE columns](references/schema-index-foreign-keys-and-lookups.md) — CRITICAL (O(n) full-table scan to O(log n) index lookup)
   - 1.5 [Store dates as integer timestamp_ms, not text](references/schema-timestamp-mode-for-dates.md) — CRITICAL (enables index-backed range queries and prevents ISO string drift)
   - 1.6 [Use integer mode 'boolean' for boolean columns](references/schema-integer-for-booleans.md) — CRITICAL (prevents 0/1 leaking into application types)
   - 1.7 [Use text mode 'json' for JSON columns, not blob](references/schema-text-json-not-blob-json.md) — HIGH (enables json_extract and indexes on JSON fields)
2. [Migrations & Drizzle Kit](references/_sections.md#2-migrations-&-drizzle-kit) — **CRITICAL**
   - 2.1 [Answer rename prompts explicitly to preserve column data](references/migrate-explicit-renames.md) — CRITICAL (prevents drop+add destroying renamed column data)
   - 2.2 [Apply migrations with the driver-specific migrator](references/migrate-apply-with-migrator.md) — HIGH (prevents re-applying or skipping migrations on repeated boots)
   - 2.3 [Commit drizzle/ migration files and snapshot to version control](references/migrate-commit-migrations-to-git.md) — HIGH (prevents diverging schemas across environments)
   - 2.4 [Configure drizzle.config.ts with dialect, schema, and out](references/migrate-config-dialect-and-out.md) — HIGH (prevents config drift between developer machines and CI)
   - 2.5 [Edit migration SQL to backfill data atomically with DDL](references/migrate-data-backfill-as-custom-sql.md) — HIGH (prevents NULL/inconsistent rows between deploy and worker run)
   - 2.6 [Use drizzle-kit generate + migrate in production, never push](references/migrate-generate-not-push-in-prod.md) — CRITICAL (prevents silent column drops and lost data)
3. [Query Building](references/_sections.md#3-query-building) — **HIGH**
   - 3.1 [Always limit listing queries](references/query-always-limit-listings.md) — HIGH (prevents unbounded memory growth as tables scale)
   - 3.2 [Bind parameters with eq/sql tagged template — never concatenate](references/query-bind-parameters-not-concat.md) — HIGH (prevents SQL injection and re-enables query plan caching)
   - 3.3 [Select only the columns you need](references/query-select-columns-not-star.md) — HIGH (2-10x payload reduction on wide tables)
   - 3.4 [Use .returning() instead of a second SELECT after write](references/query-returning-instead-of-reselect.md) — MEDIUM-HIGH (eliminates a 2nd select round trip per write)
   - 3.5 [Use .toSQL() and EXPLAIN QUERY PLAN to verify generated SQL](references/query-toSQL-and-explain.md) — MEDIUM-HIGH (prevents O(n) full-table scans reaching production)
   - 3.6 [Use inArray for batch lookups instead of looping queries](references/query-avoid-n-plus-one-with-inarray.md) — HIGH (10-100x latency reduction by eliminating per-row round trips)
   - 3.7 [Use onConflictDoUpdate/DoNothing for upsert, not select-then-write](references/query-upsert-with-onconflict.md) — HIGH (1 round trip instead of 2, eliminates TOCTOU races)
4. [Relations](references/_sections.md#4-relations) — **HIGH**
   - 4.1 [Declare relations() so db.query.* can resolve `with`](references/rel-declare-relations-for-rqb.md) — HIGH (enables single-statement nested fetches via db.query.*)
   - 4.2 [Drop to leftJoin when you need aggregates or flat shapes](references/rel-leftjoin-for-flat-aggregates.md) — MEDIUM-HIGH (prevents O(n) JS-side aggregation over hydrated rows)
   - 4.3 [Filter related rows in `with`'s where, not in JavaScript](references/rel-filter-with-where-inside-with.md) — HIGH (2-10x payload reduction on filtered nested fetches)
   - 4.4 [Use columns inside `with` to keep nested payloads small](references/rel-partial-columns-in-with.md) — HIGH (2-5x payload reduction on nested fetches)
   - 4.5 [Use db.query `with` for nested fetches, not manual joins + grouping](references/rel-prefer-with-over-manual-joins.md) — HIGH (eliminates N+1 queries and manual JS row grouping)
5. [Transactions & Batching](references/_sections.md#5-transactions-&-batching) — **MEDIUM-HIGH**
   - 5.1 [Avoid Promise.all on writes — SQLite is single-writer](references/tx-single-writer-no-parallel-writes.md) — MEDIUM-HIGH (prevents lock contention disguised as parallelism)
   - 5.2 [Handle SQLITE_BUSY with bounded retries on writes](references/tx-handle-busy-with-retry.md) — MEDIUM-HIGH (prevents transient lock contention surfacing as 500s)
   - 5.3 [Never await external I/O inside a transaction](references/tx-no-network-io-inside-transaction.md) — MEDIUM-HIGH (prevents write-lock starvation across the cluster)
   - 5.4 [Use db.batch() to collapse round trips on libsql/Turso/D1](references/tx-batch-for-libsql-roundtrips.md) — MEDIUM-HIGH (eliminates N-1 network round trips per transaction)
   - 5.5 [Wrap multi-statement writes in db.transaction()](references/tx-wrap-multi-statement-writes.md) — MEDIUM-HIGH (atomicity + 5-50x throughput on batched writes)
6. [Prepared Statements & Hot Paths](references/_sections.md#6-prepared-statements-&-hot-paths) — **MEDIUM-HIGH**
   - 6.1 [Avoid count(*) over large tables — use approximations or counters](references/perf-avoid-count-star-on-large-tables.md) — MEDIUM (O(n) full-table scan to O(1) lookup)
   - 6.2 [Build covering indexes for hot read queries](references/perf-covering-index-for-hot-queries.md) — MEDIUM-HIGH (eliminates the table row lookup after index probe)
   - 6.3 [Bulk insert with one multi-row VALUES, not a loop](references/perf-bulk-insert-multi-row-values.md) — MEDIUM-HIGH (10-100x faster than per-row inserts)
   - 6.4 [Prepare hot-path queries with sql.placeholder](references/perf-prepare-hot-paths.md) — MEDIUM-HIGH (2-5x speedup on high-frequency lookups)
   - 6.5 [Use keyset pagination for deep pages, not OFFSET](references/perf-keyset-not-offset-for-deep-pages.md) — MEDIUM-HIGH (O(n) to O(log n) on deep pages)
7. [Connection & Driver Setup](references/_sections.md#7-connection-&-driver-setup) — **MEDIUM**
   - 7.1 [Enable WAL journal mode for concurrent reads + one writer](references/conn-enable-wal.md) — MEDIUM-HIGH (10-100x tail-latency reduction under write load)
   - 7.2 [Pick a SQLite driver deliberately — sync vs async matters](references/conn-pick-driver-deliberately.md) — MEDIUM (avoids API mismatches and wrong-tool perf)
   - 7.3 [Reuse a singleton Drizzle client — don't construct per request](references/conn-singleton-client.md) — MEDIUM (keeps statement cache warm and prevents fd exhaustion)
   - 7.4 [Set busy_timeout so contention waits instead of failing](references/conn-set-busy-timeout.md) — MEDIUM (prevents transient lock contention surfacing as 500s)
   - 7.5 [Set foreign_keys = ON on every connection](references/conn-foreign-keys-pragma.md) — HIGH (prevents orphan rows from FKs that look declared)
8. [Type Inference](references/_sections.md#8-type-inference) — **MEDIUM**
   - 8.1 [Derive row types with $inferSelect and $inferInsert](references/types-infer-select-insert.md) — MEDIUM (prevents schema drift between TS and DB)
   - 8.2 [Narrow JSON column types with $type<Shape>()](references/types-narrow-json-with-dollartype.md) — MEDIUM (eliminates type casts at every JSON read site)
   - 8.3 [Pair drizzle-zod with the schema for runtime validation](references/types-drizzle-zod-for-runtime-validation.md) — MEDIUM (prevents bad inputs reaching the database)
   - 8.4 [Use bigint mode when storing values beyond Number.MAX_SAFE_INTEGER](references/types-bigint-mode-for-large-integers.md) — MEDIUM (prevents silent precision loss)
   - 8.5 [Use getTableColumns to share projections without duplicating](references/types-getTableColumns-for-reuse.md) — MEDIUM (prevents projection/schema drift across endpoints)

---

## References

1. [https://orm.drizzle.team/docs/get-started-sqlite](https://orm.drizzle.team/docs/get-started-sqlite)
2. [https://orm.drizzle.team/docs/column-types/sqlite](https://orm.drizzle.team/docs/column-types/sqlite)
3. [https://orm.drizzle.team/docs/relations](https://orm.drizzle.team/docs/relations)
4. [https://orm.drizzle.team/docs/rqb](https://orm.drizzle.team/docs/rqb)
5. [https://orm.drizzle.team/docs/transactions](https://orm.drizzle.team/docs/transactions)
6. [https://orm.drizzle.team/docs/batch-api](https://orm.drizzle.team/docs/batch-api)
7. [https://orm.drizzle.team/docs/perf-queries](https://orm.drizzle.team/docs/perf-queries)
8. [https://orm.drizzle.team/docs/drizzle-kit-generate](https://orm.drizzle.team/docs/drizzle-kit-generate)
9. [https://orm.drizzle.team/docs/drizzle-kit-migrate](https://orm.drizzle.team/docs/drizzle-kit-migrate)
10. [https://orm.drizzle.team/docs/drizzle-kit-push](https://orm.drizzle.team/docs/drizzle-kit-push)
11. [https://orm.drizzle.team/docs/drizzle-config-file](https://orm.drizzle.team/docs/drizzle-config-file)
12. [https://orm.drizzle.team/docs/zod](https://orm.drizzle.team/docs/zod)
13. [https://www.sqlite.org/lang.html](https://www.sqlite.org/lang.html)
14. [https://www.sqlite.org/pragma.html](https://www.sqlite.org/pragma.html)
15. [https://www.sqlite.org/wal.html](https://www.sqlite.org/wal.html)
16. [https://www.sqlite.org/foreignkeys.html](https://www.sqlite.org/foreignkeys.html)
17. [https://www.sqlite.org/lang_altertable.html](https://www.sqlite.org/lang_altertable.html)
18. [https://www.sqlite.org/lang_returning.html](https://www.sqlite.org/lang_returning.html)
19. [https://www.sqlite.org/lang_upsert.html](https://www.sqlite.org/lang_upsert.html)
20. [https://www.sqlite.org/eqp.html](https://www.sqlite.org/eqp.html)
21. [https://www.sqlite.org/queryplanner.html](https://www.sqlite.org/queryplanner.html)
22. [https://www.sqlite.org/json1.html](https://www.sqlite.org/json1.html)
23. [https://github.com/WiseLibs/better-sqlite3](https://github.com/WiseLibs/better-sqlite3)
24. [https://docs.turso.tech](https://docs.turso.tech)
25. [https://use-the-index-luke.com/no-offset](https://use-the-index-luke.com/no-offset)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |