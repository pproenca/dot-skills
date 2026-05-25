---
title: Redirect from the Loader When Workspace State Is Invalid
impact: MEDIUM-HIGH
impactDescription: prevents rendering layouts with null data
tags: server, redirect, workspace, defensive
---

## Redirect from the Loader When Workspace State Is Invalid

When a workspace loader returns nothing — the tenant was deleted, the session is stale, the slug doesn't exist, or the data layer denied access — the request is unsalvageable. Calling `redirect()` from inside the loader exits the render tree immediately. Components downstream never run with `workspace = null` and never need a "what if there's no workspace" branch. Returning null instead forces every consumer to handle the impossible case, and someone will forget. The principle is backend-neutral; the loader here reads through Supabase.

**Incorrect (return null and hope consumers handle it):**

```ts
export async function loadAccountWorkspace(accountSlug: string) {
  const client = getServerClient();
  const api = createAccountsApi(client);
  const workspace = await api.getAccountWorkspace(accountSlug);

  if (!workspace.data?.account) {
    return null;  // Consumer's problem now.
  }
  return workspace.data;
}

// Now every consumer has to do this:
function Page() {
  const workspace = await loadAccountWorkspace(accountSlug);
  if (!workspace) {
    notFound();  // Or redirect. Or render an error. Each page picks differently.
  }
  return <Layout workspace={workspace} />;
}
```

**Correct (loader redirects, consumers see a non-null type):**

```ts
// app/[locale]/home/[account]/_lib/server/account-workspace.loader.ts
import 'server-only';
import { cache } from 'react';
import { redirect } from 'next/navigation';
import { getServerClient } from '@app/supabase/server';
import { createAccountsApi } from '@app/accounts/api';
import { requireUserInServerComponent } from '@app/supabase/require-user';
import pathsConfig from '~/config/paths.config';

export const loadAccountWorkspace = cache(workspaceLoader);

async function workspaceLoader(accountSlug: string) {
  const client = getServerClient();
  const api = createAccountsApi(client);
  const [workspace, user] = await Promise.all([
    api.getAccountWorkspace(accountSlug),
    requireUserInServerComponent(),
  ]);

  // The data layer already scoped this read: no account row = no access (or slug typo).
  // Either way, the page can't render meaningfully — send them home.
  if (!workspace.data?.account) {
    return redirect(pathsConfig.app.home);
  }

  return { ...workspace.data, user };
}

// Consumers can rely on the return type — never null.
function Page() {
  const workspace = await loadAccountWorkspace(accountSlug);
  return <Layout workspace={workspace} />;
}
```

**Why this works in TypeScript:** Next's `redirect()` is typed `() => never`, so the compiler knows the function exits. The narrowed return type after the check is non-null automatically.

**Pick the redirect target carefully:**

| State | Where to redirect | Why |
|-------|------------------|-----|
| Slug typo / no membership | `/home` (back to workspace picker) | User picked something they can't see |
| Account exists but user signed out | `/auth/sign-in?next=...` | `requireUser` handles this — don't duplicate |
| Account deleted while user was here | `/home` with a flash message | Their previous selection is gone |
| Permission denied on a sub-resource | Stay on the page, render a "no access" component | Different problem — they CAN see the workspace |

**`notFound()` vs `redirect()`:** use `notFound()` only when the URL identifies a resource that doesn't exist (e.g., a project ID that was never valid). Use `redirect()` when the user has nowhere good to land on this URL (e.g., the workspace was deleted).

**Don't redirect from a leaf component.** The loader is the right place — it has the data, it knows the failure mode, and it runs before any layout starts rendering. A leaf component redirecting after the layout has already started rendering wastes the work the layout did.

Reference: [Next.js `redirect()`](https://nextjs.org/docs/app/api-reference/functions/redirect)
