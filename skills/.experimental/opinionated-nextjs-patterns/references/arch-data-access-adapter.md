---
title: Confine the Backend to One Data-Access Package with a Stable Surface
impact: MEDIUM
impactDescription: keeps the data store swappable and testable
tags: arch, data-access, adapter, backend
---

## Confine the Backend to One Data-Access Package with a Stable Surface

If feature code imports `@supabase/ssr` and calls `.from('table')` everywhere, the store leaks into every layer: an SDK upgrade or a move to Drizzle/Prisma means touching hundreds of call sites, and nothing is unit-testable without a live database. Put the store behind a single workspace package (`@app/supabase` here) that owns client construction and typed access; every feature depends on that surface, never on the vendor SDK directly. Swapping backends becomes one package reimplementation instead of a codebase-wide edit.

**Incorrect (the vendor SDK leaks into a feature package):**

```ts
// features/projects/server/projects.repository.ts
import { createServerClient } from '@supabase/ssr'; // vendor SDK imported in feature code
import { cookies } from 'next/headers';

export async function listProjects(accountId: string) {
  const client = createServerClient(/* url, key, cookie wiring repeated here */);
  return client.from('projects').select('*').eq('account_id', accountId);
}
```

**Correct (the feature depends only on the data-access surface):**

```ts
// features/projects/server/projects.repository.ts
import { getServerClient } from '@app/supabase/server'; // the only data-access entry point
import type { Tables } from '@app/supabase/types';

export async function listProjects(accountId: string): Promise<Tables<'projects'>[]> {
  const client = getServerClient();
  const { data } = await client.from('projects').select('*').eq('account_id', accountId);
  return data ?? [];
}
```

**The data-access package exposes one small surface** (`packages/supabase/package.json`):

```json
{
  "name": "@app/supabase",
  "exports": {
    "./server": "./src/server.ts",   // request-scoped, auth-bound client
    "./admin": "./src/admin.ts",      // privileged service-role client (guarded callers only)
    "./client": "./src/client.ts",    // memoized browser client
    "./types": "./src/types.ts"       // generated row types
  }
}
```

*Transferable:* to move off Supabase, reimplement `@app/supabase` (or publish a parallel `@app/db` built on Drizzle/Prisma) exposing the same `server` / `admin` / `client` / `types` entry points. Because feature packages import only that surface — never the vendor SDK — their code does not change. This is ports-and-adapters: the package is the port, the vendor SDK is one adapter.

Reference: [Turborepo internal packages](https://turborepo.com/docs/core-concepts/internal-packages)
