---
title: Pair drizzle-zod with the schema for runtime validation
impact: MEDIUM
impactDescription: prevents bad inputs reaching the database
tags: types, zod, validation, runtime
---

## Pair drizzle-zod with the schema for runtime validation

TypeScript types disappear at runtime — a `Pick<NewUser, ...>` parameter doesn't actually validate the user's request body. For inserts/updates from untrusted input (HTTP, queue messages, CSV import), pair the schema with `drizzle-zod`. `createInsertSchema(users)` produces a Zod schema mirroring the table — required where the column is `NOT NULL`, optional where there's a default. Add `.refine()` rules for application-level constraints the database doesn't enforce.

**Incorrect (no validation — trusts the request body shape):**

```typescript
// app/api/users/route.ts
import { type NewUser } from '@/db/schema';

export async function POST(req: Request) {
  const body = (await req.json()) as NewUser; // ❌ a cast, not a check
  // body could be anything: missing required fields, malformed email,
  // extra fields, the wrong types entirely.
  await db.insert(users).values(body);
  return new Response('ok');
}
```

**Correct (drizzle-zod derives the validator from the schema):**

```bash
npm install drizzle-zod zod
```

```typescript
// src/db/validators.ts
import { createInsertSchema, createSelectSchema, createUpdateSchema } from 'drizzle-zod';
import { z } from 'zod';
import { users } from './schema';

// Base — mirrors NOT NULL / nullable / default exactly:
export const newUserSchema = createInsertSchema(users, {
  // Tighten beyond what the database can express:
  email: (schema) => schema.email().toLowerCase(),
  name: (schema) => schema.min(1).max(120),
});

// Optional partial — for PATCH endpoints:
export const updateUserSchema = createUpdateSchema(users);

// SELECT (e.g., trusting a returned API row):
export const userSchema = createSelectSchema(users);
```

```typescript
// app/api/users/route.ts
import { newUserSchema } from '@/db/validators';

export async function POST(req: Request) {
  const parsed = newUserSchema.safeParse(await req.json());
  if (!parsed.success) {
    return Response.json({ errors: parsed.error.flatten() }, { status: 400 });
  }
  const [created] = await db.insert(users).values(parsed.data).returning();
  return Response.json(created);
}
```

**Schema-aware error messages:** `parsed.error.flatten()` gives `{ fieldErrors: { email: ['Invalid email'] } }` — exactly the shape forms need.

**For server actions / tRPC procedures:** wire `newUserSchema` directly into the input contract; the type and the validator stay in lockstep with the database forever.

**Same-file alternative if you don't want a separate validators file:**

```typescript
import { createInsertSchema } from 'drizzle-zod';

export const users = sqliteTable('users', { /* ... */ });
export const newUserSchema = createInsertSchema(users);
export type NewUserInput = typeof users.$inferInsert; // type
```

**Don't:** validate against a hand-written Zod schema separate from the Drizzle table. The two will drift. Always derive the validator from the schema.

Reference: [drizzle-zod](https://orm.drizzle.team/docs/zod) · [Zod](https://zod.dev/)
