# Conventions Enforced by drizzle-sqlite-scaffold

The templates encode 11 conventions. Each one corresponds to one or more rules in the [`drizzle-sqlite`](../../drizzle-sqlite/SKILL.md) skill — read those when an exception is required so you understand the cascade effect you're trading off.

---

## 1. Files kebab-case, tables snake_case, columns camelCase in TS

Files: `src/db/schema/user.ts`. Table identifier in TS: `user`. SQL table name: `users`. Column identifier in TS: `createdAt`. Column name in SQL: `created_at`.

The bridge is `casing: 'snake_case'` in `drizzle.config.ts` — Drizzle converts camelCase TS identifiers to snake_case SQL automatically without per-column `.column('snake_name')` calls.

**Why:** Cross-OS filesystem case sensitivity for files (Mac/Windows are case-insensitive, Linux isn't — kebab-case avoids the trap). Idiomatic TS for identifiers. Idiomatic SQL for table/column names (most query tools and ORMs assume snake_case). One central knob means renaming a TS column ports automatically to its SQL name.

**Related rule:** [`migrate-config-dialect-and-out`](../../drizzle-sqlite/references/migrate-config-dialect-and-out.md)

---

## 2. Every table has an explicit primary key

The `table.ts.template` always emits a PK definition — single-column for entities, composite for join tables. The supported `pk` modes are:

- `serial-int` → `id: integer().primaryKey({ autoIncrement: true })`
- `uuid` → `id: text().primaryKey().$defaultFn(() => crypto.randomUUID())`
- `cuid2` → `id: text().primaryKey().$defaultFn(() => createId())` (requires `@paralleldrive/cuid2`)
- `text` → `id: text().primaryKey()` (caller-supplied)

For join tables, the template uses `primaryKey({ columns: [...] })` to declare the composite key.

**Why:** SQLite still has a hidden rowid for tables without a PK, but it can be reassigned by `VACUUM`, can't be referenced by foreign keys, and `.onConflictDoUpdate()` has no target to act on.

**Related rule:** [`schema-always-primary-key`](../../drizzle-sqlite/references/schema-always-primary-key.md)

---

## 3. Timestamps are `integer({ mode: 'timestamp_ms' })` with `$defaultFn`

When `timestamps: true` (the default), the template emits:

```typescript
createdAt: integer({ mode: 'timestamp_ms' }).notNull().$defaultFn(() => new Date()),
updatedAt: integer({ mode: 'timestamp_ms' })
  .notNull()
  .$defaultFn(() => new Date())
  .$onUpdateFn(() => new Date()),
```

`$onUpdateFn` runs on every `.update()` so `updatedAt` stays current without caller help.

**Why:** SQLite stores text dates lexicographically — one stray ISO offset breaks `ORDER BY`. Epoch milliseconds index correctly, range queries are integer comparisons, Drizzle returns `Date` objects so app code never sees the storage format.

**Related rule:** [`schema-timestamp-mode-for-dates`](../../drizzle-sqlite/references/schema-timestamp-mode-for-dates.md)

---

## 4. Booleans are `integer({ mode: 'boolean' })`

Never raw `integer()` for true/false flags. The template flags this with a code comment in the column-definitions block.

**Why:** Raw `integer()` infers as `number` and leaks `0 | 1` into every consumer, breaking `=== true` checks and forcing manual conversions.

**Related rule:** [`schema-integer-for-booleans`](../../drizzle-sqlite/references/schema-integer-for-booleans.md)

---

## 5. Every foreign key has explicit `onDelete` and `onUpdate`

The template's column-definition block includes an example FK with `{ onDelete: 'cascade', onUpdate: 'cascade' }` for users to copy.

```typescript
parentId: integer()
  .notNull()
  .references(() => parents.id, { onDelete: 'cascade', onUpdate: 'cascade' }),
```

**Why:** Without these, SQLite defaults to `NO ACTION` — and FK enforcement is only active when `PRAGMA foreign_keys = ON` is set on the connection (off by default in stock SQLite). The combination silently orphans rows.

**Related rules:** [`schema-foreign-keys-with-actions`](../../drizzle-sqlite/references/schema-foreign-keys-with-actions.md), [`conn-foreign-keys-pragma`](../../drizzle-sqlite/references/conn-foreign-keys-pragma.md)

---

## 6. Every foreign key column is indexed

The template's `indexes` block reserves a line per FK column:

```typescript
(table) => [
  index('{{table_name}}_parent_idx').on(table.parentId),
]
```

**Why:** SQLite does not auto-index foreign-key columns (unlike MySQL/InnoDB). Every `WHERE parentId = ?` is a full table scan without an explicit index.

**Related rule:** [`schema-index-foreign-keys-and-lookups`](../../drizzle-sqlite/references/schema-index-foreign-keys-and-lookups.md)

---

## 7. `relations()` declared whenever a foreign key exists

Each table file ends with a `relations(table, ({ one, many }) => ({ ... }))` block. The block stays next to its column definitions so renaming the table or its columns updates the relation declarations in one place.

**Why:** Without `relations()`, `db.query.tableName.findMany({ with: { ... } })` is not typed and fails at runtime. The relational query builder is one of Drizzle's biggest ergonomic wins; unlock it by default.

**Related rule:** [`rel-declare-relations-for-rqb`](../../drizzle-sqlite/references/rel-declare-relations-for-rqb.md)

---

## 8. Repository helpers use `.returning()`, `inArray()`, `.onConflictDoUpdate()`

The `repository.ts.template` ships pre-wired CRUD methods that follow the query rules:

- `create(input)` — `db.insert(...).values(...).returning()` (one round trip)
- `createMany(inputs)` — multi-row `values([...])` (one statement)
- `findById(id)` — prepared statement with `sql.placeholder('id')` (one compile)
- `findManyByIds(ids)` — `inArray(table.id, ids)` (one statement)
- `upsert(input, { target, set })` — `.onConflictDoUpdate(...)` (atomic, race-free)
- `list({ cursor, pageSize })` — keyset pagination with `lt(...)` (constant cost)
- `update(id, changes)` / `remove(id)` — both with `.returning()`

**Why:** These patterns each fix a specific SQLite/Drizzle anti-pattern (N+1, select-then-write race, OFFSET degradation, repeated SQL compilation). Generating them by default means developers don't need to remember to reach for the right tool on each new entity.

**Related rules:** [`query-returning-instead-of-reselect`](../../drizzle-sqlite/references/query-returning-instead-of-reselect.md), [`query-upsert-with-onconflict`](../../drizzle-sqlite/references/query-upsert-with-onconflict.md), [`query-avoid-n-plus-one-with-inarray`](../../drizzle-sqlite/references/query-avoid-n-plus-one-with-inarray.md), [`perf-prepare-hot-paths`](../../drizzle-sqlite/references/perf-prepare-hot-paths.md), [`perf-keyset-not-offset-for-deep-pages`](../../drizzle-sqlite/references/perf-keyset-not-offset-for-deep-pages.md), [`perf-bulk-insert-multi-row-values`](../../drizzle-sqlite/references/perf-bulk-insert-multi-row-values.md)

---

## 9. The client sets WAL + `foreign_keys=ON` + `busy_timeout=5000` per connection

The `client.*.template` family applies these pragmas immediately after the SQLite handle is opened. Pragmas are per-connection — no shortcut, no skipping.

**Why:** Default `journal_mode=DELETE` blocks readers on writers (tail-latency spikes correlate with write traffic). Default `foreign_keys=OFF` makes every FK declaration in the schema purely decorative. Default `busy_timeout=0` makes every transient lock contention surface as an error.

**Related rules:** [`conn-enable-wal`](../../drizzle-sqlite/references/conn-enable-wal.md), [`conn-foreign-keys-pragma`](../../drizzle-sqlite/references/conn-foreign-keys-pragma.md), [`conn-set-busy-timeout`](../../drizzle-sqlite/references/conn-set-busy-timeout.md)

(libsql / Turso has FK on by default and manages journaling itself; the libsql client template omits redundant pragmas accordingly.)

---

## 10. The client is a `globalThis`-guarded module-scope singleton

```typescript
const sqlite = globalThis.__sqlite__ ?? initSqlite();
if (process.env.NODE_ENV !== 'production') {
  globalThis.__sqlite__ = sqlite;
}
```

**Why:** Constructing a new client per request leaks file descriptors and discards the prepared-statement cache. The `globalThis` guard also prevents dev-server HMR (Next.js, Vite, Bun) from leaking new connections on every hot reload.

**Related rule:** [`conn-singleton-client`](../../drizzle-sqlite/references/conn-singleton-client.md)

---

## 11. Migrations: `drizzle-kit generate` → review → `drizzle-kit migrate`

The `drizzle.config.*.template` is set up so:
- `npx drizzle-kit generate` writes SQL files into `{{migrations_dir}}/`
- `npx drizzle-kit migrate` applies unapplied files
- The client templates also call `migrate(db, { migrationsFolder: '{{migrations_dir}}' })` on boot for serverless/container deploys

**Never** `drizzle-kit push` against production. The `gitignore.template` explicitly keeps `{{migrations_dir}}/meta/` tracked so the next `generate` can compute correct diffs.

**Why:** `push` diffs against the live DB without an SQL artifact for review and can't tell renames from drop+add — destructive against production. The meta/ snapshots are how the next generate computes the diff; gitignoring them produces "recreate all tables" SQL.

**Related rules:** [`migrate-generate-not-push-in-prod`](../../drizzle-sqlite/references/migrate-generate-not-push-in-prod.md), [`migrate-commit-migrations-to-git`](../../drizzle-sqlite/references/migrate-commit-migrations-to-git.md), [`migrate-apply-with-migrator`](../../drizzle-sqlite/references/migrate-apply-with-migrator.md)

---

## When to break a convention

These conventions are defaults, not laws. Reach for an exception when:

- **Schema convention** — you're migrating an existing database with an existing shape. Match the existing convention rather than rewriting; the [`drizzle-sqlite`](../../drizzle-sqlite/SKILL.md) rules still apply.
- **Repository convention** — you have a query pattern that doesn't fit `findById/list/upsert` (e.g., a cross-table aggregate). Write a custom function alongside the generated repository; don't bend `list` to do something it wasn't designed for.
- **Client convention** — you're targeting Cloudflare D1, where the client is per-request (instantiated from `env.DB` inside the handler) and the singleton pattern doesn't apply. Follow the [Cloudflare D1 + Drizzle guide](https://orm.drizzle.team/docs/get-started/d1-new) for the right shape.

When you do break a convention, leave a comment naming the rule you're trading off. Future readers (human and AI) will thank you.
