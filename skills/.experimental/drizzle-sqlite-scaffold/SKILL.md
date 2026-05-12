---
name: drizzle-sqlite-scaffold
description: Use this skill whenever scaffolding Drizzle ORM + SQLite boilerplate — a new `drizzle.config.ts`, a singleton client with the right pragmas, per-table schema files with explicit primary keys/indexed foreign keys/relations()/inferred types, per-table repository modules with `.returning()` + `inArray()` + `.onConflictDoUpdate()`, or drizzle-zod validators. Produces convention-enforced templates for three drivers (better-sqlite3, libsql/Turso, bun:sqlite). Trigger even when the user doesn't say "scaffold" — phrases like "add a table for X", "set up Drizzle in this project", "wire up SQLite", "create a CRUD module for X", or "bootstrap the DB layer" should pull this in. Pairs with the `drizzle-sqlite` skill, which covers the 45 rules these templates encode — read it when an exception is required.
---

# Drizzle SQLite Scaffold

Parameterized templates for bootstrapping Drizzle + SQLite in a fresh project, or adding a new table/repository to an existing one. Every output bakes in the conventions documented in [`references/conventions.md`](references/conventions.md) — explicit primary keys, indexed foreign keys, `relations()` declarations, `$inferSelect`/`$inferInsert` exports, timestamp_ms dates, boolean-mode bools, WAL + `foreign_keys=ON` + `busy_timeout` pragmas, singleton client with HMR guard, and CRUD helpers using `.returning()` + `inArray()` + `.onConflictDoUpdate()`.

## When to Apply

Reach for these templates when:
- Starting a new project that will use Drizzle with SQLite (any driver)
- Adding a new table to an existing Drizzle project — the table file should match the existing patterns
- Adding a CRUD repository module for an existing table
- Refactoring a hand-rolled Drizzle setup that's missing pragmas, has no `relations()`, or has hand-written `User` types that drift from the schema
- Migrating from another ORM (Prisma, Kysely) to Drizzle and wanting consistent shapes from the start

## Setup

### Required parameters (asked on first use, saved to `config.json`)

| Parameter | Required | Default | Values |
|-----------|----------|---------|--------|
| `driver` | yes | — | `better-sqlite3` \| `libsql` \| `bun-sqlite` (D1 has a different lifecycle — see "Cloudflare D1" below) |
| `db_url_env` | no | `DATABASE_URL` | env var name |
| `schema_dir` | no | `./src/db/schema` | per-table schema files |
| `repository_dir` | no | `./src/db/repository` | per-table CRUD modules |
| `validators_dir` | no | `./src/db/validators` | drizzle-zod schemas (when `with_zod=true`) |
| `client_path` | no | `./src/db/client.ts` | singleton client module |
| `migrations_dir` | no | `./drizzle` | drizzle-kit output |

If `config.json` already exists with values, this skill uses them; otherwise it asks via `AskUserQuestion`.

### Per-table parameters (asked each time a new table is scaffolded)

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `name` | yes | — | Kebab-case singular: `user`, `order-item`. Used for filenames and TS identifiers (`name_camel`, `name_pascal` derived). |
| `table_name` | no | snake_case plural of `name` | SQL table name: `users`, `order_items` |
| `pk` | no | `serial-int` | `serial-int` \| `uuid` \| `cuid2` \| `text` |
| `timestamps` | no | `true` | adds `createdAt`/`updatedAt` columns |
| `soft_delete` | no | `false` | adds nullable `deletedAt` + partial index |
| `relations` | no | `[]` | list of related table names — expands `relations()` body |
| `with_zod` | no | `true` | emits a drizzle-zod validators file |

## Available Templates

### Project-init templates (emit once)

| Template | Output File | When |
|----------|-------------|------|
| [`drizzle.config.local.ts.template`](assets/templates/drizzle.config.local.ts.template) | `drizzle.config.ts` | `driver` is `better-sqlite3`, `bun-sqlite`, or `libsql` with a `file:` URL |
| [`drizzle.config.turso.ts.template`](assets/templates/drizzle.config.turso.ts.template) | `drizzle.config.ts` | `driver` is `libsql` against Turso (remote `libsql:` URL) |
| [`client.better-sqlite3.ts.template`](assets/templates/client.better-sqlite3.ts.template) | `{{client_path}}` | `driver` is `better-sqlite3` |
| [`client.libsql.ts.template`](assets/templates/client.libsql.ts.template) | `{{client_path}}` | `driver` is `libsql` |
| [`client.bun-sqlite.ts.template`](assets/templates/client.bun-sqlite.ts.template) | `{{client_path}}` | `driver` is `bun-sqlite` |
| [`schema-index.ts.template`](assets/templates/schema-index.ts.template) | `{{schema_dir}}/index.ts` | Always (initially empty; append exports as tables are added) |
| [`gitignore.template`](assets/templates/gitignore.template) | `.gitignore` (append) | Always |

### Per-table templates (emit once per table)

| Template | Output File | When |
|----------|-------------|------|
| [`table.ts.template`](assets/templates/table.ts.template) | `{{schema_dir}}/{{name}}.ts` | Per table |
| [`repository.ts.template`](assets/templates/repository.ts.template) | `{{repository_dir}}/{{name}}.ts` | Per table |
| [`validators.ts.template`](assets/templates/validators.ts.template) | `{{validators_dir}}/{{name}}.ts` | Per table when `with_zod=true` |

## How to Use

### Flow A — Initialize a new project (run once)

1. **Resolve project parameters.** Read `config.json`. For any required field that's empty, ask the user via `AskUserQuestion` (driver is the only strictly required one; the rest have sensible defaults).

2. **Install runtime + tooling first** so the rendered files type-check immediately:
   ```bash
   # Pick the driver-specific runtime package:
   npm install drizzle-orm @libsql/client      # for libsql
   npm install drizzle-orm better-sqlite3      # for better-sqlite3
   npm install drizzle-orm                     # bun:sqlite is built into Bun

   # Dev tools (all drivers):
   npm install -D drizzle-kit
   npm install -D @types/better-sqlite3        # better-sqlite3 only
   npm install -D drizzle-zod zod              # if with_zod=true
   ```

3. **Pick the config and client variants** for the resolved `driver`:
   - `better-sqlite3` → `drizzle.config.local.ts.template` + `client.better-sqlite3.ts.template`
   - `libsql` with `file:` URL → `drizzle.config.local.ts.template` + `client.libsql.ts.template`
   - `libsql` with remote Turso URL → `drizzle.config.turso.ts.template` + `client.libsql.ts.template`
   - `bun-sqlite` → `drizzle.config.local.ts.template` + `client.bun-sqlite.ts.template`

4. **Render and write the project-init files:**
   - `drizzle.config.ts`
   - `{{client_path}}` (typically `src/db/client.ts`)
   - `{{schema_dir}}/index.ts` (empty barrel)
   - Append the `gitignore.template` block to the project's `.gitignore`

5. **For libsql:** the client template uses top-level `await migrate(...)`. Verify `tsconfig.json` has `"module": "ESNext"` (or `"NodeNext"`) and `"target": "ES2022"+` for top-level await support. If the runtime is CommonJS, replace the top-level await with an exported `async function init()` the app calls during startup.

6. **Save resolved values to `config.json`** so subsequent table runs don't re-prompt.

### Flow B — Add a new table (run per table)

1. **Resolve per-table parameters.** Ask the user for `name`, then offer defaults for `table_name` (snake_case plural), `pk`, `timestamps`, `soft_delete`, `relations`, `with_zod`. Use `AskUserQuestion` for any non-default the user wants.

2. **Compute derived identifiers:**
   - `name_camel` — camelCase of `name` (`user`, `orderItem`)
   - `name_pascal` — PascalCase of `name` (`User`, `OrderItem`)
   - `pk_field` — the PK column name (`id` for all 4 `pk` modes)
   - `pk_ts_type` — TS type for the PK (`number` for `serial-int`, `string` for `uuid`/`cuid2`/`text`)
   - `pk_definition` — the actual line, e.g., `id: integer().primaryKey({ autoIncrement: true }),` (see PK Variants table below)

3. **Render the table template:** Read `table.ts.template`, substitute `{{name}}`, `{{name_camel}}`, `{{name_pascal}}`, `{{table_name}}`, `{{pk_definition}}`, `{{pk_extra_imports}}`, etc. Expand `{{timestamps_block}}` and `{{soft_delete_block}}` per the parameters (see "Block Expansions" below). Write to `{{schema_dir}}/{{name}}.ts`.

4. **Render the repository template** with the same parameters. Write to `{{repository_dir}}/{{name}}.ts`.

5. **If `with_zod=true`**, render the validators template. Write to `{{validators_dir}}/{{name}}.ts`.

6. **Append to the schema barrel:** Add `export * from './{{name}}';` to `{{schema_dir}}/index.ts`.

7. **Generate the migration:** Tell the user to run `npx drizzle-kit generate` to produce the SQL file. Remind them to answer rename prompts explicitly if this scaffold replaces an existing differently-named table.

8. **Apply the migration:** Run `npx drizzle-kit migrate` against the dev database. The client templates also call `migrate(...)` on boot, but applying once in the dev loop confirms the SQL works before the next process restart.

### Flow C — Add a CRUD module for an existing table (no schema change)

Same as Flow B steps 1-2, but skip the table.ts.template render and just emit the repository (and optionally validators) modules.

## PK Variants

| `pk` value | `pk_definition` | `pk_ts_type` | Extra imports |
|---|---|---|---|
| `serial-int` (default) | `id: integer().primaryKey({ autoIncrement: true }),` | `number` | — |
| `uuid` | `id: text().primaryKey().$defaultFn(() => crypto.randomUUID()),` | `string` | — (uses Web Crypto) |
| `cuid2` | `id: text().primaryKey().$defaultFn(() => createId()),` | `string` | `import { createId } from '@paralleldrive/cuid2';` |
| `text` | `id: text().primaryKey(),` | `string` | — (caller supplies the ID) |

## Placeholder Reference

Every `{{placeholder}}` the templates use, with its derivation rule. Items marked **simple sub** are find-and-replace; items marked **block** require the agent to expand per the rules in the next section.

| Placeholder | Type | Source / derivation |
|---|---|---|
| `{{driver}}` | simple sub | `config.json:driver` |
| `{{db_url_env}}` | simple sub | `config.json:db_url_env` |
| `{{schema_dir}}` | simple sub | `config.json:schema_dir` |
| `{{repository_dir}}` | simple sub | `config.json:repository_dir` |
| `{{validators_dir}}` | simple sub | `config.json:validators_dir` |
| `{{client_path}}` | simple sub | `config.json:client_path` |
| `{{migrations_dir}}` | simple sub | `config.json:migrations_dir` |
| `{{schema_index_import}}` | simple sub | derived: `client_path` → relative path to `{{schema_dir}}/index.ts` (typically `'./schema'`) |
| `{{client_import}}` | simple sub | derived: from a repository file, relative path back to `client_path` (typically `'../client'`) |
| `{{schema_import}}` | simple sub | derived: from a repository or validators file, relative path to the matching table file (typically `'../schema/{{name}}'`) |
| `{{name}}` | simple sub | per-table param — kebab-case singular (`user`) |
| `{{name_camel}}` | simple sub | derived from `name` (`user`, `orderItem`) |
| `{{name_pascal}}` | simple sub | derived from `name` (`User`, `OrderItem`) |
| `{{table_name}}` | simple sub | per-table param, default = snake_case plural of `name` (`users`, `order_items`) |
| `{{pk}}` | metadata | per-table param — `serial-int` \| `uuid` \| `cuid2` \| `text` (drives the rows below) |
| `{{pk_definition}}` | block | the actual PK column line — see "PK Variants" table |
| `{{pk_field}}` | simple sub | always `id` for the four PK variants this skill ships |
| `{{pk_ts_type}}` | simple sub | `number` for `serial-int`, `string` for `uuid` / `cuid2` / `text` |
| `{{pk_extra_imports}}` | block | empty for `serial-int` / `uuid` / `text`; `import { createId } from '@paralleldrive/cuid2';` for `cuid2` |
| `{{relation_imports}}` | block | for each table in `relations[]`, emit `import { {{relatedCamel}} } from './{{related-kebab}}';` |
| `{{domain_columns}}` | block | the agent (or user) replaces this with the actual non-PK, non-timestamp columns for the entity. Leave as a TODO comment if the user hasn't provided them yet. |
| `{{timestamps_block}}` | block | see expansion below — emit when `timestamps=true`, remove the line entirely when `false` |
| `{{soft_delete_block}}` | block | see expansion below — emit in the columns block when `soft_delete=true` |
| `{{indexes}}` | block | one `index(...)` line per foreign key column (and any composite `(authorId, publishedAt)`-style indexes the user wants) |
| `{{soft_delete_index}}` | block | the partial index on `deletedAt` (see expansion below); emit only when `soft_delete=true` |
| `{{relations_body}}` | block | one `one(...)` / `many(...)` line per related table; see expansion below |
| `{{insert_refinements}}` | block | drizzle-zod refinement callbacks for the INSERT shape; leave the example comment if none provided |
| `{{update_refinements}}` | block | same for the partial UPDATE shape |
| `{{exports}}` | block | inside `schema-index.ts.template`: one `export * from './{{name}}';` line per table; append on each new-table run |

If a template emits a `{{placeholder}}` not in this table, that's a bug — file it under `gotchas.md`.

## Block Expansions

The `table.ts.template` uses placeholder *blocks* for variable-shaped sections — the agent must expand them per parameters, not just text-substitute.

### `{{timestamps_block}}` (when `timestamps=true`)

```typescript
createdAt: integer({ mode: 'timestamp_ms' })
  .notNull()
  .$defaultFn(() => new Date()),
updatedAt: integer({ mode: 'timestamp_ms' })
  .notNull()
  .$defaultFn(() => new Date())
  .$onUpdateFn(() => new Date()),
```

When `timestamps=false`, remove the line entirely (don't leave the comment marker).

### `{{soft_delete_block}}` (when `soft_delete=true`)

In the columns block:

```typescript
deletedAt: integer({ mode: 'timestamp_ms' }),
```

In the indexes block:

```typescript
index('{{table_name}}_active_idx').on(table.deletedAt).where(sql`deleted_at IS NULL`),
```

(Adjust the `sql` import accordingly.)

### `{{relations_body}}` (when `relations` is non-empty)

For each related table in `relations[]`, the agent decides whether it's a `one` or `many` based on whether the FK lives on the current table (then it's `one`) or on the related table (then it's `many`):

```typescript
// FK on current table — `one`:
parent: one(parents, { fields: [users.parentId], references: [parents.id] }),

// FK on related table — `many`:
posts: many(posts),
```

If the user can't easily tell, default to one example of each and leave a comment.

### `{{indexes}}` block

For each FK column, emit:

```typescript
index('{{table_name}}_{{column}}_idx').on(table.{{columnCamel}}),
```

## Cloudflare D1 note

D1 has a different lifecycle: the client is constructed per request from `env.DB` (the binding), not as a module-level singleton. This skill doesn't ship a D1 client template — follow the [official D1 + Drizzle guide](https://orm.drizzle.team/docs/get-started/d1-new) for the wiring. The `table.ts.template`, `repository.ts.template`, and `validators.ts.template` are still usable with D1 — only the client module differs.

## Reference Files

| File | Description |
|------|-------------|
| [references/conventions.md](references/conventions.md) | The 11 conventions enforced, with WHY and rule cross-references |
| [gotchas.md](gotchas.md) | Edge cases discovered over time |
| [metadata.json](metadata.json) | Version + driver references |
| [config.json](config.json) | Project-level parameter store |

## Related Skills

- **[`drizzle-sqlite`](../drizzle-sqlite/SKILL.md)** — The library-reference rules these templates encode. The conventions doc cites specific rule filenames from it. Read it when you need to make an informed exception, debug a generated file, or scaffold something outside the templates' scope (custom migrations, complex queries, performance work).
- **[`better-auth-scaffold`](../better-auth-scaffold/SKILL.md)** — Scaffolds Better Auth on top of a Drizzle DB; can be run after this skill provides the client.
