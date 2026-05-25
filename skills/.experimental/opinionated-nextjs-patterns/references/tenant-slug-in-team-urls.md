---
title: Put a Human-Readable Tenant Slug in Team URLs, Not the Tenant UUID
impact: HIGH
impactDescription: prevents UUID leakage in URLs and decouples routing from primary keys
tags: tenant, slug, routing, app-router
---

## Put a Human-Readable Tenant Slug in Team URLs, Not the Tenant UUID

Team workspace URLs follow `/home/[account]/...` where `[account]` is the human-readable slug, not the tenant's UUID. UUIDs in URLs leak through HTTP referrers, web-server logs, and shared links; they are user-hostile; and they bind every link to an internal primary key, so a future "transfer ownership and re-key the tenant" operation would break them all. The slug is one extra `where slug = ?` lookup per request, performed once by the workspace loader and reused across the layout with React `cache()`.

**Incorrect (UUID-in-URL):**

```tsx
// app/[locale]/home/[id]/billing/page.tsx
async function BillingPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;                       // 'a3f2c9d1-...-...'
  const client = getServerClient();
  // Filtering by id works, but the URL itself leaks a UUID.
  const { data: account } = await client.from('accounts').select('*').eq('id', id).single();
  return <Billing account={account} />;
}

// URL becomes /home/a3f2c9d1-7b3e-4f5a-9c12-abcdef012345/billing
// Try sharing that with a teammate.
```

**Correct (slug-in-URL, resolved server-side):**

```tsx
// app/[locale]/home/[account]/billing/page.tsx
import { loadTeamWorkspace } from '../_lib/server/team-account-workspace.loader';

async function BillingPage({
  params,
}: {
  params: Promise<{ account: string }>;
}) {
  const { account } = await params;                  // 'acme'
  // Loader is cache()'d, so the layout's resolution is reused here — one lookup.
  const workspace = await loadTeamWorkspace(account);
  return <Billing account={workspace.account} />;
}

// URL becomes /home/acme/billing — readable, shareable, stable.
```

**The cached loader that resolves the slug once per request:**

```ts
// app/[locale]/home/[account]/_lib/server/team-account-workspace.loader.ts
import { cache } from 'react';
import { redirect } from 'next/navigation';
import { createTeamAccountsApi } from '@app/accounts/api';
import { getServerClient } from '@app/supabase/server';
import { requireUserInServerComponent } from '@app/supabase/require-user';

export const loadTeamWorkspace = cache(workspaceLoader);

async function workspaceLoader(accountSlug: string) {
  const api = createTeamAccountsApi(getServerClient());
  const [workspace, user] = await Promise.all([
    api.getAccountWorkspace(accountSlug),
    requireUserInServerComponent(),
  ]);

  if (!workspace.data?.account) {
    // The data layer already scoped the read: no row means no access (or a slug typo).
    return redirect('/home');
  }
  return { ...workspace.data, user };
}
```

**Slug validation belongs in the create flow, not the URL handler.** Enforce a slug regex in your Zod schema (`/^[a-z0-9][a-z0-9-]{1,40}$/`) so the URL handler can assume the slug is well-formed and a `not found` genuinely means "no such tenant."

**Personal workspaces use `/home`, not `/home/[me-slug]`.** Put them in a user-scoped route group `(user)` that carries no path parameter — distinguish personal from team in the router, not via slugs.

Reference: [Next.js dynamic route segments](https://nextjs.org/docs/app/api-reference/file-conventions/dynamic-routes)
