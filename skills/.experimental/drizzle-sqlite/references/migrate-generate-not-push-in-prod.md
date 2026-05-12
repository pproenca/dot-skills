---
title: Use drizzle-kit generate + migrate in production, never push
impact: CRITICAL
impactDescription: prevents silent column drops and lost data
tags: migrate, drizzle-kit, production, data-loss
---

## Use drizzle-kit generate + migrate in production, never push

`drizzle-kit push` introspects the live database, diffs it against the schema file, and applies the inferred changes directly — there's no SQL artifact, no review step, and the diff engine cannot tell a rename from a drop-then-add. Run it against production and a column you renamed in code becomes a `DROP COLUMN` against the database. The `generate` + `migrate` flow writes SQL files into `./drizzle/`, gives you a review/commit/PR-review step, and applies them in order with a recorded log table.

**Incorrect (push against prod — destructive, no audit trail):**

```bash
# Developer renames `userId` to `ownerId` in src/schema.ts, then:
npx drizzle-kit push
# drizzle-kit sees "no userId in schema, no ownerId in DB" → DROP + ADD.
# Production data in that column is gone.
```

**Correct (generate, review, migrate):**

```bash
# 1. Generate a versioned SQL migration into ./drizzle/
npx drizzle-kit generate
#    drizzle-kit will prompt: "is owner_id a rename of user_id?" — answer yes.
#    File ./drizzle/0007_rename_user_to_owner.sql is created.

# 2. Open the file, verify the SQL (ALTER ... RENAME COLUMN), commit it.

# 3. Apply in CI/deploy:
npx drizzle-kit migrate
#    drizzle-kit migrate applies every unapplied file in order and records
#    them in __drizzle_migrations.
```

**When `push` is fine:**
- Local development of a brand-new schema where you don't care about data.
- Throwaway test databases that are re-seeded on every run.

**Programmatic apply at boot (e.g., serverless/Turso):**

```typescript
import { drizzle } from 'drizzle-orm/libsql';
import { migrate } from 'drizzle-orm/libsql/migrator';

const db = drizzle(client);
await migrate(db, { migrationsFolder: './drizzle' });
```

Reference: [Drizzle Kit — generate](https://orm.drizzle.team/docs/drizzle-kit-generate) · [Drizzle Kit — migrate](https://orm.drizzle.team/docs/drizzle-kit-migrate) · [Drizzle Kit — push](https://orm.drizzle.team/docs/drizzle-kit-push)
