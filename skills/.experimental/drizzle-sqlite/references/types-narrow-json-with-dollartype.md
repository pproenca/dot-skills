---
title: Narrow JSON column types with $type<Shape>()
impact: MEDIUM
impactDescription: eliminates type casts at every JSON read site
tags: types, json, dollar-type, schema
---

## Narrow JSON column types with $type<Shape>()

A JSON column declared as `text({ mode: 'json' })` (or `blob({ mode: 'json' })`) infers as `unknown` — Drizzle has no way to know what shape the document has. Reads then need `as` casts at every callsite, and writes accept arbitrary objects. `.$type<MyShape>()` tells Drizzle's type inference what the document looks like. The compile-time type narrows; the runtime stays as opaque JSON.

**Incorrect (`unknown` everywhere — casts proliferate):**

```typescript
import { sqliteTable, integer, text } from 'drizzle-orm/sqlite-core';

export const userPrefs = sqliteTable('user_prefs', {
  userId: integer().primaryKey(),
  settings: text({ mode: 'json' }).notNull(), // inferred as `unknown`
});

const [prefs] = await db.select().from(userPrefs);
const theme = (prefs.settings as { theme: string }).theme; // cast at every read site
```

**Correct (`$type<Shape>()` — inferred everywhere):**

```typescript
import { sqliteTable, integer, text } from 'drizzle-orm/sqlite-core';

type Settings = {
  theme: 'light' | 'dark' | 'system';
  notifications: { email: boolean; push: boolean };
  shortcuts: Record<string, string>;
};

export const userPrefs = sqliteTable('user_prefs', {
  userId: integer().primaryKey(),
  settings: text({ mode: 'json' }).$type<Settings>().notNull(),
});

const [prefs] = await db.select().from(userPrefs);
const theme = prefs.settings.theme; // typed as 'light' | 'dark' | 'system'

// Writes are checked too:
await db.update(userPrefs)
  .set({ settings: { theme: 'dark', notifications: { email: true, push: false }, shortcuts: {} } })
  .where(eq(userPrefs.userId, userId));
```

**$type is type-only — there's no runtime validation.**

Reading a row whose JSON was written before you added a field returns `undefined` at that path despite the TypeScript shape claiming otherwise. For long-lived JSON columns, validate at the boundary:

```typescript
import { z } from 'zod';

const settingsSchema = z.object({
  theme: z.enum(['light', 'dark', 'system']),
  notifications: z.object({ email: z.boolean(), push: z.boolean() }),
  shortcuts: z.record(z.string()),
});
type Settings = z.infer<typeof settingsSchema>;

// $type matches the validated shape:
settings: text({ mode: 'json' }).$type<Settings>().notNull(),

// At read time:
const raw = (await db.select().from(userPrefs).where(eq(userPrefs.userId, userId)))[0];
const settings = settingsSchema.parse(raw.settings); // throws if shape drifted
```

**Same pattern for enum-style text columns — `text({ enum: [...] })`:**

```typescript
// Native enum inference — no $type needed:
status: text({ enum: ['active', 'paused', 'cancelled'] }).notNull(),
// Inferred: 'active' | 'paused' | 'cancelled'
```

**For partial / discriminated unions in JSON, `$type` keeps the discriminator inferred:**

```typescript
type Event =
  | { kind: 'click'; element: string }
  | { kind: 'view'; path: string };

export const events = sqliteTable('events', {
  id: integer().primaryKey(),
  payload: text({ mode: 'json' }).$type<Event>().notNull(),
});
```

Reference: [Drizzle — Type customizations ($type)](https://orm.drizzle.team/docs/column-types/sqlite#text) · [Drizzle — Custom types](https://orm.drizzle.team/docs/custom-types)
