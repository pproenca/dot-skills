---
title: Apply migrations with the driver-specific migrator
impact: HIGH
impactDescription: prevents re-applying or skipping migrations on repeated boots
tags: migrate, migrator, drizzle-kit, atomicity
---

## Apply migrations with the driver-specific migrator

Each Drizzle driver ships its own `migrator` module — `drizzle-orm/better-sqlite3/migrator`, `drizzle-orm/libsql/migrator`, `drizzle-orm/bun-sqlite/migrator`. They read the `./drizzle/` folder, look up the `__drizzle_migrations` log table to see what's already applied, apply unapplied files in order, and record the result. Running migrations any other way (raw `sqlite3 < file.sql`, hand-applied SQL) skips the bookkeeping and the same migration can run twice. Pair the migrator with `drizzle-kit migrate` for the CLI flow, and use the programmatic API for serverless deployments that apply on boot.

**Incorrect (apply manually — no idempotency record):**

```typescript
import { readFileSync } from 'node:fs';
import Database from 'better-sqlite3';

const sqlite = new Database('app.db');
sqlite.exec(readFileSync('./drizzle/0001_init.sql', 'utf8'));
// On next deploy, this re-applies and fails on "table already exists".
```

**Correct (CLI for traditional deploys):**

```bash
# Run as a deploy step:
npx drizzle-kit migrate
# Reads drizzle.config.ts, applies unapplied files, records into __drizzle_migrations.
```

**Alternative (programmatic apply on boot — serverless / containers):**

```typescript
import Database from 'better-sqlite3';
import { drizzle } from 'drizzle-orm/better-sqlite3';
import { migrate } from 'drizzle-orm/better-sqlite3/migrator';

const sqlite = new Database(process.env.DATABASE_URL ?? './app.db');
const db = drizzle(sqlite);

migrate(db, { migrationsFolder: './drizzle' });
// Safe to call on every boot — already-applied files are skipped.

export { db };
```

**libsql / Turso variant — async, same idea:**

```typescript
import { createClient } from '@libsql/client';
import { drizzle } from 'drizzle-orm/libsql';
import { migrate } from 'drizzle-orm/libsql/migrator';

const db = drizzle(createClient({
  url: process.env.TURSO_DATABASE_URL!,
  authToken: process.env.TURSO_AUTH_TOKEN!,
}));

await migrate(db, { migrationsFolder: './drizzle' });
```

**When NOT to apply at boot:**
- Multi-instance deploys where many containers boot concurrently — run the migration as a single pre-deploy job instead to avoid lock contention on the migrations table.

Reference: [Drizzle — Migrations (Migration runner)](https://orm.drizzle.team/docs/migrations)
