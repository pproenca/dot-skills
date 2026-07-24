---
title: Mark the db module server-only and keep schema imports separate
tags: conn, server-only, client-components, bundling
---

## Mark the db module server-only and keep schema imports separate

Nothing in the App Router stops a `'use client'` file from importing `db`. The import does not fail loudly — the bundler follows it, drags the driver and `process.env.DATABASE_URL` into the client graph, and you find out from a cryptic runtime error about `net` or `fs`, or worse, from a connection string in a source map. `import 'server-only'` turns that into a build-time error naming the offending file. Keep it on the module that constructs the client, not on the schema file: schema tables are just metadata objects, and client code legitimately imports types derived from them.

```typescript
// lib/db/index.ts — the client. Importing this from a client component fails the build.
import 'server-only'
import { drizzle } from 'drizzle-orm/node-postgres'
import * as schema from './schema'

export const db = drizzle(process.env.DATABASE_URL!, { schema })
```

```typescript
// lib/db/schema.ts — no 'server-only' here; types below must reach client components.
import { pgTable, text, timestamp, integer } from 'drizzle-orm/pg-core'

export const invoices = pgTable('invoices', {
  id: integer().primaryKey().generatedAlwaysAsIdentity(),
  reference: text().notNull().unique(),
  issuedAt: timestamp({ withTimezone: true }).notNull().defaultNow(),
})

export type Invoice = typeof invoices.$inferSelect
```

Reference: [Next.js — Keeping Server-only Code out of the Client Environment](https://nextjs.org/docs/app/getting-started/server-and-client-components#preventing-environment-poisoning)
