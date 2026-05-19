---
title: Wrap Per-Request Loaders with `cache()` from React
impact: HIGH
impactDescription: prevents N duplicate queries across nested layouts
tags: server, cache, react, loader, dedup
---

## Wrap Per-Request Loaders with `cache()` from React

A root layout calls `loadWorkspace()`, a nested layout calls it again, the page calls it a third time — without memoization, that's three Supabase round-trips per render. `cache()` from `react` memoizes the call within a single request: every consumer of the loader gets the same Promise, the same data, and pays for one round-trip. The function MUST be hoisted to module scope (not redeclared per call) for the memoization to work.

**Incorrect (no memoization — every layout fetches):**

```ts
// app/[locale]/home/[account]/_lib/server/team-account-workspace.loader.ts
import { redirect } from 'next/navigation';

export async function loadTeamWorkspace(accountSlug: string) {
  const client = getSupabaseServerClient();
  const api = createTeamAccountsApi(client);
  const [workspace, user] = await Promise.all([
    api.getAccountWorkspace(accountSlug),
    requireUserInServerComponent(),
  ]);
  if (!workspace.data?.account) return redirect(pathsConfig.app.home);
  return { ...workspace.data, user };
}

// Layout calls loadTeamWorkspace('acme')  → query 1
// Nested layout calls loadTeamWorkspace('acme')  → query 2 (same data!)
// Page calls loadTeamWorkspace('acme')  → query 3 (same data!)
```

**Correct (the shipped pattern — `cache()` wraps the loader at module scope):**

```ts
// app/[locale]/home/[account]/_lib/server/team-account-workspace.loader.ts
import 'server-only';  // The team-account loader has this; the user-workspace loader doesn't.
                        // Add it to any loader file that imports Supabase clients.
import { cache } from 'react';
import { redirect } from 'next/navigation';

export const loadTeamWorkspace = cache(workspaceLoader);

async function workspaceLoader(accountSlug: string) {
  const client = getSupabaseServerClient();
  const api = createTeamAccountsApi(client);
  const [workspace, user] = await Promise.all([
    api.getAccountWorkspace(accountSlug),
    requireUserInServerComponent(),
  ]);
  if (!workspace.data?.account) return redirect(pathsConfig.app.home);
  return { ...workspace.data, user };
}

// Layout calls loadTeamWorkspace('acme')  → query 1, cached
// Nested layout calls loadTeamWorkspace('acme')  → cache hit
// Page calls loadTeamWorkspace('acme')  → cache hit
```

**`cache()` keys on argument identity.** `loadTeamWorkspace('acme')` and `loadTeamWorkspace('beta')` are independent cache entries — calling both yields two queries (one each), not one shared one. Same `'acme'` argument across the tree returns the same Promise.

**Cache lifetime is the request, not the user session.** Each new request starts with an empty cache. This is what you want — a mutation in one request shouldn't be invisible in the next.

**The argument MUST be serialisable.** `cache()` keys by reference equality for objects — passing `loadX({slug: 'acme'})` creates a new object each call and defeats memoization. Pass primitives, or destructure them out of an object before calling:

```ts
// Incorrect — object key changes every render.
const workspace = await loadTeamWorkspace({ slug: account });

// Correct — primitive argument, stable across renders for same slug.
const workspace = await loadTeamWorkspace(account);
```

**Don't put `cache()` inside the component.** That creates a new memoization closure on every render, which is worse than no caching at all.

```ts
// Incorrect — cache() runs on every render, never reuses.
function Page() {
  const load = cache(workspaceLoader);
  return load('acme');
}

// Correct — cache() at module scope, shared across the tree.
export const loadWorkspace = cache(workspaceLoader);
function Page() { return loadWorkspace('acme'); }
```

Reference: [React `cache()` API](https://react.dev/reference/react/cache)
