---
title: Pick the Adapter That Matches Your ORM, Not the Default
impact: CRITICAL
impactDescription: prevents runtime type errors and schema drift between Better Auth and your app
tags: db, adapter, drizzle, prisma, kysely, mongodb
---

## Pick the Adapter That Matches Your ORM, Not the Default

Better Auth ships a built-in Kysely SQL adapter by default, plus first-class adapters for Drizzle, Prisma, and MongoDB. If your application already uses Drizzle or Prisma, using the matching adapter is essential — it shares the same client, connection pool, and TypeScript types, and lets you run migrations through your existing toolchain. Using the wrong adapter (or the raw Pool default when you have an ORM) creates two parallel schema definitions that drift, two connection pools competing for limits, and types that don't match what the rest of your code sees.

**Incorrect (Drizzle app using raw Pool default):**

```typescript
// lib/auth.ts
import { betterAuth } from "better-auth";
import { Pool } from "pg";

// App uses Drizzle, but auth bypasses it — duplicates schema and pool
export const auth = betterAuth({
  database: new Pool({ connectionString: process.env.DATABASE_URL }),
});
```

**Correct (Drizzle adapter sharing the app's db instance):**

```typescript
// lib/auth.ts
import { betterAuth } from "better-auth";
import { drizzleAdapter } from "better-auth/adapters/drizzle";
import { db } from "@/db"; // your existing Drizzle instance

export const auth = betterAuth({
  database: drizzleAdapter(db, {
    provider: "pg", // or "mysql" or "sqlite"
  }),
});
```

**Alternative (Prisma app):**

```typescript
import { betterAuth } from "better-auth";
import { prismaAdapter } from "better-auth/adapters/prisma";
import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

export const auth = betterAuth({
  database: prismaAdapter(prisma, {
    provider: "postgresql", // or "mysql", "sqlite", ...
  }),
});
```

**Alternative (MongoDB):**

```typescript
import { betterAuth } from "better-auth";
import { mongodbAdapter } from "better-auth/adapters/mongodb";
import { client } from "@/db";

export const auth = betterAuth({
  database: mongodbAdapter(client),
});
```

Reference: [Better Auth — Adapters](https://www.better-auth.com/docs/adapters/drizzle)
