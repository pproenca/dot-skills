# Sections

This file defines the categories and their order. The prefix in parentheses is
the filename prefix that groups rules. Order categories by **importance** — the
decisions that come up most often and cost most when wrong go first.

---

## 1. Client Construction & Driver Choice (conn)

**Description:** The `db` module is instantiated once per process and inherited by every Server Component, Server Action, and Route Handler, so its defaults are the hardest thing to change later. Postgres is a client/server database with a hard `max_connections` ceiling, and Next.js multiplies process count in two directions: HMR replaces module instances on every save in dev, and serverless scales instances horizontally in prod. Driver choice is a capability decision, not a style one — `neon-http` throws on `db.transaction`, and TCP drivers cannot run where sockets are unavailable.

## 2. Reads in Server Components (rsc)

**Description:** Next.js 16's Cache Components model makes data fetching dynamic by default and prerenders a static shell around it, which changes where a Drizzle query is allowed to sit in the tree. The pre-16 vocabulary a model reaches for — `unstable_cache`, `export const revalidate`, `noStore()` — has been replaced by `use cache` / `cacheLife` / `cacheTag`, and the new cache has different persistence and different key semantics than the one it replaces.

## 3. Server Actions & Mutations (mut)

**Description:** A Server Action is a public HTTP endpoint with a generated ID, reachable by anyone who can guess it, so every authorization and validation check must live inside the action body. After the write lands, the read caches built in category 2 are stale until explicitly invalidated, and Next.js 16 offers two invalidation APIs with materially different freshness guarantees.

## 4. Postgres Schema Definition (schema)

**Description:** Drizzle presents a uniform column API across dialects, but Postgres semantics leak through it: `timestamp` is not a point in time, `numeric` is not a JS number, and `bigint` is wider than `Number.MAX_SAFE_INTEGER`. These choices are encoded into migrations within minutes and cost a backfill to reverse.

## 5. Migrations & Schema Change Safety (migrate)

**Description:** `drizzle-kit` generates SQL from a schema diff, but it does not reason about production locks, deployment concurrency, or intent behind a rename. Postgres DDL takes locks that block reads and writes on a live table, and Drizzle's own `migrate()` runs every pending file inside a single transaction — which silently rules out the statements that exist specifically to avoid those locks.

## 6. Transactions & Pooled Connections (tx)

**Description:** In Postgres a transaction pins one backend connection for its entire body, so transaction duration and pool size are the same resource. Concurrency also becomes visible here in ways SQLite never surfaces: read-modify-write races need explicit row locks, and `serializable` transactions abort under contention with an error the caller is expected to retry.

## 7. Postgres Query Building (query)

**Description:** The queries that pass review at 100 rows are the ones that fail at a million. Postgres has no stored row count, `OFFSET` discards rows it has already read, `NOT IN` inverts on a single NULL, and prepared statements are named server-side objects that a transaction-mode pooler will not preserve.
