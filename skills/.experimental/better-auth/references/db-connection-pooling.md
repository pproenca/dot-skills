---
title: Share One Pooled Database Client With the Rest of Your App
impact: HIGH
impactDescription: prevents connection exhaustion on serverless platforms (Vercel, Lambda)
tags: db, connection-pool, serverless, performance
---

## Share One Pooled Database Client With the Rest of Your App

In serverless deployments (Vercel Functions, AWS Lambda, Cloudflare Workers with hyperdrive), each cold start opens a new database connection. If your auth instance has its own `Pool` separate from the app's ORM client, you double the open connections per instance — and at concurrency limits you hit `too many connections` errors that look like random auth failures. The fix is to pass the same client both Better Auth and your application code use.

**Incorrect (Drizzle app, Better Auth opens a second Pool):**

```typescript
// db.ts
import { drizzle } from "drizzle-orm/node-postgres";
import { Pool } from "pg";

const pool = new Pool({ connectionString: process.env.DATABASE_URL });
export const db = drizzle(pool);
```

```typescript
// lib/auth.ts
import { betterAuth } from "better-auth";
import { Pool } from "pg";

export const auth = betterAuth({
  database: new Pool({ connectionString: process.env.DATABASE_URL }), // ← second pool
});
```

**Correct (Better Auth uses the same Drizzle client):**

```typescript
// lib/auth.ts
import { betterAuth } from "better-auth";
import { drizzleAdapter } from "better-auth/adapters/drizzle";
import { db } from "@/db";

export const auth = betterAuth({
  database: drizzleAdapter(db, { provider: "pg" }),
});
```

**With Prisma (use the singleton pattern that survives HMR):**

```typescript
// db.ts
import { PrismaClient } from "@prisma/client";

const globalForPrisma = globalThis as unknown as { prisma?: PrismaClient };
export const prisma = globalForPrisma.prisma ?? new PrismaClient();
if (process.env.NODE_ENV !== "production") globalForPrisma.prisma = prisma;
```

```typescript
// lib/auth.ts
import { betterAuth } from "better-auth";
import { prismaAdapter } from "better-auth/adapters/prisma";
import { prisma } from "@/db";

export const auth = betterAuth({
  database: prismaAdapter(prisma, { provider: "postgresql" }),
});
```

**Common use cases:**
- For very high concurrency on traditional Postgres, layer a connection pooler (PgBouncer, Neon, Supabase Pooler) in front — Better Auth and your ORM both go through it.

Reference: [Better Auth — Database: Connection Pooling](https://www.better-auth.com/docs/concepts/database)
