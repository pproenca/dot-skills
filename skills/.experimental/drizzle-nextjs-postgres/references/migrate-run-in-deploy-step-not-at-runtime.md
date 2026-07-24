---
title: Run migrations as a deploy step, not from application code
tags: migrate, deployment, instrumentation, concurrency
---

## Run migrations as a deploy step, not from application code

Calling `migrate()` from `instrumentation.ts` or at the top of the db module is appealing because it guarantees the schema matches the code — and it is a race. Serverless starts many instances at once, so several processes call `migrate()` simultaneously against the same database; Drizzle's migration table is read before the transaction, so concurrent cold starts can each decide the same file is pending. The failure modes range from a duplicate-object error that crashes a deploy to a partially-applied change nobody notices. It also puts DDL on the request path: the first user after a deploy waits for the migration, and a slow one exceeds the function timeout and gets killed mid-transaction.

```typescript
// scripts/migrate.ts — run by the platform's release command, once per deploy
import { drizzle } from 'drizzle-orm/node-postgres'
import { migrate } from 'drizzle-orm/node-postgres/migrator'

// Use the DIRECT connection string here, not the pooled one: DDL and advisory
// locks need a stable session, which a transaction-mode pooler does not give.
const db = drizzle(process.env.DIRECT_DATABASE_URL!)
await migrate(db, { migrationsFolder: './drizzle' })
process.exit(0)
```

Wire it to the platform's dedicated release/pre-deploy hook — a single process that runs after the build and before traffic shifts to the new version. Reaching for `"build": "drizzle-kit migrate && next build"` instead is a trap on platforms like Vercel: the build step runs for *every* deployment including previews, so a preview build migrates whatever `DATABASE_URL` resolves to in that environment — often the production database. Only fall back to the build hook when the platform offers no separate release step, and then guard it so previews cannot reach production.

The direct-connection detail matters as much as the placement — see [`conn-disable-prepare-behind-transaction-pooler`](conn-disable-prepare-behind-transaction-pooler.md) for why a transaction-mode pooler cannot hold the session that DDL assumes.

Reference: [Drizzle — drizzle-kit migrate](https://orm.drizzle.team/docs/drizzle-kit-migrate) · [Drizzle — Migrations](https://orm.drizzle.team/docs/migrations)
