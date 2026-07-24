---
title: Set prepare false when postgres-js runs behind a transaction-mode pooler
tags: conn, postgres-js, pgbouncer, supavisor, prepared-statements
---

## Set prepare false when postgres-js runs behind a transaction-mode pooler

`postgres-js` prepares statements by default, which is the right default against a real Postgres backend and fatal through a transaction-mode pooler. A prepared statement is server-side state bound to one backend connection; transaction mode hands your client a *different* backend between transactions, so the `PREPARE` lands on one connection and the `EXECUTE` arrives at another that has never heard of it. The symptom is an intermittent `prepared statement "s1" does not exist` under load — it passes in local dev against a direct connection and fails in production behind the pooler, which makes it easy to misread as a networking problem.

```typescript
// lib/db/index.ts — Supabase/PgBouncer transaction-mode connection string
import 'server-only'
import postgres from 'postgres'
import { drizzle } from 'drizzle-orm/postgres-js'
import * as schema from './schema'

const client = postgres(process.env.DATABASE_URL!, { prepare: false })

export const db = drizzle(client, { schema })
```

Session-mode poolers keep one backend per client connection for its lifetime, so prepared statements work there and `prepare: false` is unnecessary. Note that migrations should still run over the direct (non-pooled) connection — see [`migrate-run-in-deploy-step-not-at-runtime`](migrate-run-in-deploy-step-not-at-runtime.md).

Reference: [Drizzle — Connect to Supabase](https://orm.drizzle.team/docs/connect-supabase) · [PgBouncer — Feature matrix for pooling modes](https://www.pgbouncer.org/features.html)
