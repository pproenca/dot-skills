---
title: Derive row types with $inferSelect and $inferInsert
impact: MEDIUM
impactDescription: prevents schema drift between TS and DB
tags: types, infer, type-inference, derived-types
---

## Derive row types with $inferSelect and $inferInsert

Hand-writing a `type User = { id: number; email: string; ... }` next to your Drizzle table works exactly once — the moment you add a column or change a mode, the type and the schema disagree silently. Drizzle exposes inferred types: `typeof users.$inferSelect` is the shape returned by reads, `typeof users.$inferInsert` is the shape accepted by writes (with optional fields for defaults). These are derived from the schema at compile time, so changing the schema updates every consumer.

**Incorrect (hand-written type — drifts from the schema):**

```typescript
// src/db/schema.ts
export const users = sqliteTable('users', {
  id: integer().primaryKey({ autoIncrement: true }),
  email: text().notNull().unique(),
  emailVerified: integer({ mode: 'boolean' }).notNull().default(false),
  createdAt: integer({ mode: 'timestamp_ms' }).notNull().$defaultFn(() => new Date()),
});

// src/types.ts
export type User = {
  id: number;
  email: string;
  // Forgot `emailVerified`; `createdAt` written as string by mistake:
  createdAt: string;
};
```

**Correct (inferred — single source of truth):**

```typescript
// src/db/schema.ts
import { type InferInsertModel, type InferSelectModel } from 'drizzle-orm';

export const users = sqliteTable('users', { /* ...as above */ });

// Two equivalent ways to expose the types — pick one:
export type User = typeof users.$inferSelect;
export type NewUser = typeof users.$inferInsert;

// Or via the imported helpers:
export type UserAlt = InferSelectModel<typeof users>;
export type NewUserAlt = InferInsertModel<typeof users>;
```

**`$inferSelect` vs `$inferInsert`:**

```typescript
type User = typeof users.$inferSelect;
// { id: number; email: string; emailVerified: boolean; createdAt: Date }
// ↑ Every column required; nullable columns are `| null`.

type NewUser = typeof users.$inferInsert;
// { id?: number; email: string; emailVerified?: boolean; createdAt?: Date }
// ↑ Columns with defaults ($defaultFn, .default(), autoIncrement) are optional.
```

**Use them at API boundaries — share types between server and client:**

```typescript
// shared/types.ts (consumed by both frontend and backend)
import type { User } from '@/db/schema';

export type UserResponse = Pick<User, 'id' | 'email' | 'createdAt'>;
// Excludes emailVerified — explicit projection for the public API.
```

**Re-deriving with computed columns or transformations:**

If you serialize `createdAt` to ISO string in your JSON response, expose a separate type:

```typescript
type UserResponse = Omit<User, 'createdAt'> & { createdAt: string };
```

Don't change the schema type to lie about the database — the database returns `Date` (per `mode: 'timestamp_ms'`), and any transformation is at the serialization boundary.

Reference: [Drizzle — Type inference](https://orm.drizzle.team/docs/goodies#type-api)
