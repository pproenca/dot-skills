---
title: Use Account Slug in Team URLs, Not the Account UUID
impact: HIGH
impactDescription: prevents UUID leakage in URLs and decouples routing from primary keys
tags: tenant, slug, routing, app-router
---

## Use Account Slug in Team URLs, Not the Account UUID

Team workspace URLs follow `/home/[account]/...` where `[account]` is the human-readable slug stored on `accounts.slug` — not the UUID. UUIDs in URLs leak through HTTP referrers, web logs, and shared links; they are user-hostile; and they bind URLs to internal primary keys (so a future "transfer ownership and re-key the account" operation would break every link). The slug indirection is one extra `where slug = ?` lookup per request, performed once by the workspace loader and reused across the layout via `cache()`.

**Incorrect (UUID-in-URL):**

```tsx
// app/[locale]/home/[id]/billing/page.tsx
async function BillingPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;                       // 'a3f2c9d1-...-...'
  const client = getSupabaseServerClient();
  // Filtering by id works, but the URL itself leaks a UUID.
  const { data } = await client.from('accounts').select('*').eq('id', id).single();
  return <Billing account={data} />;
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
  // Loader is cached() so the layout's resolution is reused here.
  const workspace = await loadTeamWorkspace(account);
  return <Billing account={workspace.account} />;
}

// URL becomes /home/acme/billing — readable, shareable, stable.
```

**The loader pattern that supports this (from the kit):**

```ts
// app/[locale]/home/[account]/_lib/server/team-account-workspace.loader.ts
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

  if (!workspace.data?.account) {
    // RLS already filtered: if no row, user has no access (or slug typo).
    return redirect(pathsConfig.app.home);
  }
  return { ...workspace.data, user };
}
```

**Slug validation belongs in the create flow, not the URL handler.** Reserve a slug regex in your Zod schema (`/^[a-z0-9][a-z0-9-]{1,40}$/`) so the URL handler can assume the slug is well-formed and a `not found` is genuinely "no such account."

**Personal accounts use `/home`, not `/home/[me-slug]`.** Personal workspaces use the user-scoped route group `(user)` which carries no path parameter — distinguish them in the router, not via slugs.

Reference: [Makerkit URL & routing conventions](https://makerkit.dev/docs/next-supabase-turbo/configuration/routing)
