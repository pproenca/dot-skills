---
title: Treat Generated DB Types as Build Output — Regenerate, Never Hand-Edit
impact: HIGH
impactDescription: prevents silent type/schema drift
tags: tenant, supabase, typescript, codegen
---

## Treat Generated DB Types as Build Output — Regenerate, Never Hand-Edit

The database type definitions are generated from the live schema, the same way a bundle is generated from source. Hand-editing them makes the types lie: the compiler signs off on a query shape the database will reject (or worse, accept with unexpected nulls). Treat the generated file as a checked-in build artifact — regenerate after every migration, commit the diff alongside the SQL change, and reference tables through the generated `Tables<'name'>` helper so consumers pick up schema changes automatically instead of hand-rolling parallel interfaces that silently drift.

**Incorrect (hand-add a column to the generated type):**

```ts
// packages/supabase/src/database.types.ts  (generated — do not edit)
// "Just added the column to the type — I'll run the migration later."
export interface Database {
  public: {
    Tables: {
      projects: {
        Row: {
          id: string;
          account_id: string;
          name: string;
          archived: boolean;     // <-- hand-added; not in the DB yet
          created_at: string;
        };
        // Insert/Update types don't match the new field either.
      };
    };
  };
}

// Code that reads `project.archived` compiles fine.
// At runtime every row returns archived: undefined.
// First user to hit the toggle: NotNullViolation from Postgres.
```

**Correct (write the migration, regenerate, commit both):**

```bash
# 1. Add the column in the schema file.
#    apps/web/supabase/schemas/20-projects.sql
#    alter table public.projects add column archived boolean not null default false;

# 2. Reset the local DB so the schema files re-apply (if developing locally).
supabase db reset

# 3. Regenerate types from the live schema.
supabase gen types typescript --local > packages/supabase/src/database.types.ts

# 4. Commit the SQL change AND the regenerated types together.
git add apps/web/supabase/schemas/20-projects.sql \
        packages/supabase/src/database.types.ts
```

**Correct (reference tables via `Tables<'name'>` — auto-updates on regen):**

```ts
import type { Database, Tables } from '@app/supabase/types';

// `Tables<'projects'>` is `Database['public']['Tables']['projects']['Row']`.
// New columns appear automatically the next time generation runs.
type Project = Tables<'projects'>;

// For writes, use the generated insert/update types:
type ProjectInsert = Database['public']['Tables']['projects']['Insert'];
type ProjectUpdate = Database['public']['Tables']['projects']['Update'];

function createProject(values: ProjectInsert) {
  // The insert type knows which columns have defaults and which are required.
}
```

**Incorrect (hand-roll a parallel row type — drifts on every schema change):**

```ts
// Wrong the moment a migration adds a column.
interface Project {
  id: string;
  account_id: string;
  name: string;
}
```

**When you genuinely need a custom shape, derive it — never duplicate it:**

```ts
type ProjectSummary = Pick<Tables<'projects'>, 'id' | 'name' | 'archived'>;
type ProjectWithOwner = Tables<'projects'> & { owner: Tables<'accounts'> };
```

**Why this isn't bureaucracy:** the generated file is thousands of lines of machine output. Diffing a hand-edit against a regeneration is impossible in review — the change either rolls forward cleanly with the migration or it gets silently clobbered. Treat it like a build artifact that happens to be committed.

*Transferable:* the principle is "generated DB types are output, not source." Drizzle and Prisma generate types the same way — from `drizzle-kit` introspection or `prisma generate` — so the same rule holds: change the schema, re-run the generator, commit the diff, and never edit the emitted file by hand.

Reference: [Supabase generating TypeScript types](https://supabase.com/docs/guides/api/rest/generating-types)
