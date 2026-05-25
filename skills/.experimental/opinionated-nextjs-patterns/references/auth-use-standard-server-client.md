---
title: Read Through the Request-Scoped Auth-Bound Client, Never the Privileged Client by Default
impact: CRITICAL
impactDescription: prevents cross-tenant data leaks
tags: auth, data-client, authorization, supabase
---

## Read Through the Request-Scoped Auth-Bound Client, Never the Privileged Client by Default

Build two server clients in `@app/supabase` and reach for the request-scoped one by default. The request-scoped client carries the caller's identity, so the data layer — Postgres RLS here — filters every row to what that user may see. The privileged client uses the service-role key and bypasses every policy; defaulting to it turns each query into a potential cross-tenant leak. Authorize at the data layer and trust it instead of re-deriving tenant checks in TypeScript.

**Incorrect (service-role client for a routine read — bypasses RLS):**

```ts
import { getServiceRoleClient } from '@app/supabase/admin';

export async function loadWorkspace() {
  const client = getServiceRoleClient(); // service role: sees every account's rows
  const { data } = await client.from('accounts').select('*').single();
  return data;
}
```

**Correct (request-scoped client — identity-bound, RLS-filtered):**

```ts
import { getServerClient } from '@app/supabase/server';

export async function loadWorkspace() {
  const client = getServerClient(); // RLS filters to the caller's own accounts
  const { data } = await client.from('accounts').select('*').single();
  return data;
}
```

**The request-scoped client is a thin wrapper you own** (`@app/supabase/server.ts`) — built on `@supabase/ssr`, never a vendored helper:

```ts
import 'server-only';
import { cookies } from 'next/headers';
import { createServerClient } from '@supabase/ssr';
import type { Database } from '@app/supabase/types';

export function getServerClient() {
  const store = cookies(); // forwards the auth cookie, so RLS sees the user's JWT
  return createServerClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll: () => store.getAll(),
        setAll: (items) =>
          items.forEach(({ name, value, options }) => store.set(name, value, options)),
      },
    },
  );
}
```

**When the privileged client is legitimate** — always authorize *before* constructing it:

- Webhook handlers where there is no authenticated user (payment provider, DB webhook).
- Cross-tenant administrative reads inside a super-admin-guarded action.
- Pre-auth lookups (e.g. reading an invitation token before the invitee signs in).

*Transferable:* the principle is "queries run under the caller's authority, enforced at the data layer." With Postgres that boundary is RLS; with another store (Drizzle, Prisma) enforce the same scoping in a repository or policy that every read passes through — and keep a separate, explicitly-guarded path for privileged access.

Reference: [Supabase server-side auth for Next.js](https://supabase.com/docs/guides/auth/server-side/nextjs)
