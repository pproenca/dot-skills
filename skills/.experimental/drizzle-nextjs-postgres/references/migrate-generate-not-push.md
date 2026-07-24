---
title: Generate and review migration files; keep push for local prototyping
tags: migrate, drizzle-kit, push, review
---

## Generate and review migration files; keep push for local prototyping

`drizzle-kit push` is the command that appears first in the getting-started guide, so it becomes the deployment workflow by default. It does not produce an artifact: it diffs the schema against a live database and applies the result immediately, with no file to review, no record of what ran, and no way to reproduce the same change on another environment. When the diff is ambiguous — a renamed column, a narrowed type — it resolves the ambiguity by dropping and recreating, and the data is gone before anyone reads the SQL. `generate` writes the same diff to a file you can read, edit, and commit, which is the only point at which a destructive statement can be caught.

```bash
# Development: edit schema.ts, then produce a reviewable migration
npx drizzle-kit generate

# Read drizzle/0007_*.sql before it goes anywhere near a real database.
# Commit it alongside the schema change so the two can never drift.

# Deploy: apply pending files in order
npx drizzle-kit migrate
```

```typescript
// drizzle.config.ts
import 'dotenv/config'
import { defineConfig } from 'drizzle-kit'

export default defineConfig({
  dialect: 'postgresql',
  schema: './lib/db/schema.ts',
  out: './drizzle',
  dbCredentials: { url: process.env.DATABASE_URL! },
})
```

`push` earns its place against a local database you are willing to drop — iterating on a schema's shape before committing to any of it. The line is whether losing the data would matter.

Reference: [Drizzle — drizzle-kit generate](https://orm.drizzle.team/docs/drizzle-kit-generate) · [Drizzle — drizzle-kit push](https://orm.drizzle.team/docs/drizzle-kit-push)
