---
title: Use `Tables<'name'>` for Row Types, Not Hand-Written Interfaces
impact: MEDIUM
impactDescription: prevents schema drift in application types
tags: server, types, supabase, codegen, tables
---

## Use `Tables<'name'>` for Row Types, Not Hand-Written Interfaces

`Tables<'projects'>` from `@kit/supabase/database` resolves to `Database['public']['Tables']['projects']['Row']` — exactly what the generated types say. Migration → `pnpm supabase:web:typegen` → consumers update automatically. A hand-written interface diverges silently as soon as a column is added or renamed, and the type error doesn't surface until something blows up at runtime.

**Incorrect (hand-rolled type — diverges on schema change):**

```ts
// Looked correct when this was written. After the migration that
// added `archived: boolean` and renamed `name → title`, it lies.
interface Project {
  id: string;
  account_id: string;
  name: string;          // Now `title` in the DB. Reads return undefined.
  created_at: string;
  // No `archived` field — UI shows everything regardless of archived state.
}

function ProjectCard({ project }: { project: Project }) {
  return <div>{project.name}</div>;  // Always blank now.
}
```

**Correct (`Tables<'name'>` — updates atomically with typegen):**

```ts
import { Tables } from '@kit/supabase/database';

// One source of truth: the generated types.
// New columns appear on the next `pnpm supabase:web:typegen`.
type Project = Tables<'projects'>;

function ProjectCard({ project }: { project: Project }) {
  return <div>{project.title}</div>;  // Refactor surfaces this — compile error.
}
```

**Correct (Insert and Update types for mutations):**

```ts
import { Database } from '@kit/supabase/database';

type ProjectRow = Database['public']['Tables']['projects']['Row'];
type ProjectInsert = Database['public']['Tables']['projects']['Insert'];
type ProjectUpdate = Database['public']['Tables']['projects']['Update'];

// Insert type marks defaulted columns as optional.
// Update type marks every column as optional.
async function createProject(data: ProjectInsert) {
  return await client.from('projects').insert(data);
}

async function patchProject(id: string, changes: ProjectUpdate) {
  return await client.from('projects').update(changes).eq('id', id);
}
```

**Correct (derived types for specific shapes — never parallel definitions):**

```ts
// Subset of columns:
type ProjectSummary = Pick<Tables<'projects'>, 'id' | 'title' | 'archived'>;

// Joined shape:
type ProjectWithOwner = Tables<'projects'> & {
  owner: Pick<Tables<'accounts'>, 'id' | 'name' | 'picture_url'>;
};

// Returned by a specific RPC:
type WorkspaceData = Database['public']['Views']['user_account_workspace']['Row'];
```

**`Tables<>` vs explicit `Database['public']['Tables']['x']['Row']`:** functionally identical. `Tables<>` is shorter and idiomatic in the kit. Use the long form when you need the Insert/Update variants.

**Why this is more than aesthetics:** the generated `database.types.ts` is ~10k lines. Diffing a hand-edit against a typegen pass is impossible in code review — your edit either rolls forward cleanly with the schema, or it gets lost in the noise of the next regeneration. Treat the types as a generated artifact; never edit them, always derive from them.

**When you genuinely need a custom shape that the DB doesn't model:** define an interface in app code, but make sure it doesn't *redeclare* anything that's already in the DB. Use `Tables<>` for the DB-modeled parts and extend.

Reference: [Supabase Generated Types](https://supabase.com/docs/guides/api/rest/generating-types)
