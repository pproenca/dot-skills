---
title: Use the Standard Server Client for RLS-Enforced Reads
impact: CRITICAL
impactDescription: prevents cross-tenant data leaks
tags: auth, supabase, rls, server-client
---

## Use the Standard Server Client for RLS-Enforced Reads

`getSupabaseServerClient()` carries the user's JWT and lets Postgres RLS filter every row. The admin client (`getSupabaseServerAdminClient()`) uses the service role key and bypasses every policy — defaulting to it turns each query into a potential cross-tenant leak. RLS is the authoritative authorization boundary; trust it instead of re-implementing tenant checks in TypeScript.

**Incorrect (admin client for routine read — bypasses RLS):**

```ts
import { getSupabaseServerAdminClient } from '@kit/supabase/server-admin-client';

export async function loadWorkspace() {
  const client = getSupabaseServerAdminClient(); // service role: sees every account
  const { data } = await client.from('accounts').select('*').single();
  return data;
}
```

**Correct (standard client — JWT-bound, RLS-filtered):**

```ts
import { getSupabaseServerClient } from '@kit/supabase/server-client';

export async function loadWorkspace() {
  const client = getSupabaseServerClient(); // RLS filters to user's own accounts
  const { data } = await client.from('accounts').select('*').single();
  return data;
}
```

**When to use the admin client:**
- Webhook handlers where there is no authenticated user (Stripe, DB webhook).
- Multi-tenant administrative reads inside a super-admin-guarded action.
- Cross-tenant operations (e.g., reading an invitation token before the invitee is logged in).

In each case, perform the authorization check *before* constructing the admin client.

Reference: [Makerkit Supabase clients](https://makerkit.dev/docs/next-supabase-turbo/data-fetching/supabase-clients-server-actions)
