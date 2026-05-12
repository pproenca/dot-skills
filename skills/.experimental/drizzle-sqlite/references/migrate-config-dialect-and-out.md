---
title: Configure drizzle.config.ts with dialect, schema, and out
impact: HIGH
impactDescription: prevents config drift between developer machines and CI
tags: migrate, drizzle-kit, config, drizzle-config
---

## Configure drizzle.config.ts with dialect, schema, and out

Without `drizzle.config.ts`, every `drizzle-kit` invocation needs `--dialect`, `--schema`, `--out`, and credentials on the command line — easy to drift between developer machines and CI. Define them once in `drizzle.config.ts` so `npx drizzle-kit generate` and `npx drizzle-kit migrate` work with no flags. `dialect: 'sqlite'` is the local file/better-sqlite3 mode; `dialect: 'turso'` enables libsql-specific features (auth token, remote URL).

**Incorrect (no config — flags everywhere, drift between dev and CI):**

```bash
# Each developer runs a slightly different command:
npx drizzle-kit generate --dialect=sqlite --schema=./src/db/schema.ts --out=./drizzle
# CI has its own copy that's one flag behind, etc.
```

**Correct (single config file, zero-flag commands):**

```typescript
// drizzle.config.ts
import 'dotenv/config';
import { defineConfig } from 'drizzle-kit';

export default defineConfig({
  dialect: 'sqlite',                   // or 'turso' for libsql remote
  schema: './src/db/schema.ts',        // glob ok: './src/db/schema/*.ts'
  out: './drizzle',
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
  // Recommended for SQLite:
  casing: 'snake_case',                // schema can use camelCase, SQL stays snake_case
  verbose: true,
  strict: true,                        // ask before destructive ops in `push`
});
```

```bash
npx drizzle-kit generate
npx drizzle-kit migrate
npx drizzle-kit studio
```

**For Turso (remote libsql):**

```typescript
export default defineConfig({
  dialect: 'turso',
  schema: './src/db/schema.ts',
  out: './drizzle',
  dbCredentials: {
    url: process.env.TURSO_DATABASE_URL!,
    authToken: process.env.TURSO_AUTH_TOKEN!,
  },
});
```

Reference: [Drizzle config file](https://orm.drizzle.team/docs/drizzle-config-file)
