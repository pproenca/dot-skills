---
title: Commit drizzle/ migration files and snapshot to version control
impact: HIGH
impactDescription: prevents diverging schemas across environments
tags: migrate, git, snapshot, version-control
---

## Commit drizzle/ migration files and snapshot to version control

`drizzle-kit generate` writes two things into `./drizzle/`: the SQL files (`0001_init.sql`, `0002_add_slug.sql`) and a `meta/_journal.json` + per-migration snapshot files. The snapshots are how the next `generate` knows the previous schema state — without them, the diff is computed against an empty schema and you get a "drop everything and re-create" migration. **Both** the SQL files and `meta/` must be committed; gitignoring either breaks future generation. Also commit `drizzle.config.ts` so every developer and CI uses the same configuration.

**Incorrect (.gitignore swallows the snapshots — next generate produces garbage):**

```gitignore
# .gitignore — common mistake
drizzle/meta/
drizzle/*.json
```

When the next developer runs `drizzle-kit generate`, drizzle-kit sees no prior snapshot, treats the schema as new, and emits SQL that recreates every table — destroying all data on apply.

**Correct (commit everything under drizzle/, gitignore only the local DB):**

```gitignore
# Local databases — never commit
*.db
*.db-journal
*.db-wal
*.db-shm
local.db*

# Drizzle Studio cache — safe to ignore
.drizzle-studio/

# DO commit:
#   drizzle/0001_*.sql
#   drizzle/0002_*.sql
#   drizzle/meta/_journal.json
#   drizzle/meta/0000_snapshot.json
#   drizzle/meta/0001_snapshot.json
#   drizzle.config.ts
```

**Pull request checklist for schema changes:**

1. `npx drizzle-kit generate` — answer rename prompts.
2. Open the generated `./drizzle/000X_*.sql`; verify it does what you intended.
3. If a data backfill is needed, hand-edit the file (see [migrate-data-backfill-as-custom-sql](migrate-data-backfill-as-custom-sql.md)).
4. `git add drizzle/ src/db/schema.ts drizzle.config.ts`.
5. Open PR; require review on the generated SQL just like any other code.

**For monorepos:** put `./drizzle/` next to each schema (e.g., `apps/api/drizzle/`, `apps/worker/drizzle/`) rather than sharing one folder — the journal is per-schema.

Reference: [Drizzle Kit — generate workflow](https://orm.drizzle.team/docs/drizzle-kit-generate)
