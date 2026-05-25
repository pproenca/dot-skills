---
title: Centralize the Auth Gate in One `requireUser()` Helper Instead of Scattering Raw Claim Checks
impact: CRITICAL
impactDescription: prevents skipping the MFA verification gate
tags: auth, mfa, require-user, redirect
---

## Centralize the Auth Gate in One `requireUser()` Helper Instead of Scattering Raw Claim Checks

Build one `requireUser()` helper in `@app/supabase` (on top of `@supabase/ssr`'s `auth.getClaims()`) that does three things atomically: validate the JWT, decide whether MFA is required for this account, and return the correct `redirectTo` for whichever check failed. Calling `client.auth.getClaims()` directly at each call site skips the MFA branch — a user with MFA enrolled but only AAL1 in their JWT passes the claim check and reaches protected pages. Scattering that raw call also means every loader re-derives the same redirect logic slightly differently.

**Incorrect (raw claims check at the call site — skips MFA):**

```ts
const client = getServerClient();
const { data, error } = await client.auth.getClaims();

if (!data?.claims || error) {
  redirect('/auth/sign-in');
}

// data.claims.aal may be 'aal1' even though the user has MFA enrolled —
// this loader now serves protected data to a half-authenticated session.
const userId = data.claims.sub;
```

**Correct (delegate to the helper you own — discriminated union return):**

```ts
import { requireUser } from '@app/supabase/require-user';
import { getServerClient } from '@app/supabase/server';

const client = getServerClient();
const auth = await requireUser(client);

if (auth.error) {
  // redirectTo points to /auth/sign-in OR /auth/verify as appropriate.
  redirect(auth.redirectTo);
}

// auth.data is typed — id, email, isSuperAdmin, aal, etc.
const userId = auth.data.id;
```

**The helper is a thin wrapper you own** (`@app/supabase/require-user.ts`), built on `@supabase/ssr`:

```ts
import 'server-only';
import type { SupabaseClient } from '@supabase/supabase-js';

export async function requireUser(
  client: SupabaseClient,
  { verifyMfa = true } = {},
) {
  const { data, error } = await client.auth.getClaims();
  if (error || !data?.claims) {
    return { error: true, redirectTo: '/auth/sign-in' } as const;
  }
  // The single place that knows MFA enrolled + AAL1 means "not done yet".
  if (verifyMfa && data.claims.aal === 'aal1' && data.claims.amr?.length) {
    return { error: true, redirectTo: '/auth/verify' } as const;
  }
  return { error: false, data: { id: data.claims.sub, ...data.claims } } as const;
}
```

**Why the discriminated union matters:** the narrowing forces you to handle the error case before reading `auth.data`. There is no way to silently use a stale or missing user.

**`verifyMfa: false` only when you have a reason:** the MFA verify page itself calls `requireUser(client, { verifyMfa: false })` because it *is* the destination. Everywhere else the default `true` is what you want.

**Pair this with the proxy MFA gate.** See `auth-mfa-in-middleware` — enforcement happens at the request boundary in `proxy.ts`; `requireUser()` is the per-context helper that produces the right redirect target.

**Where to call it:**

| Context | Pattern |
|---------|---------|
| Server Component / loader | A wrapper around `requireUser` that performs the redirect |
| Server Action | Use `authActionClient` — it calls `requireUser` and injects `ctx.user` |
| Route Handler | A route wrapper whose `auth: true` calls `requireUser` |
| Webhook | `auth: false` — no user; verify a signature instead |

*Transferable:* the principle is "one chokepoint owns the auth-plus-step-up decision and the redirect target." Supabase claims and AAL are the concrete check here; with another provider, still funnel every protected read through a single helper so the MFA/session-posture branch can never be forgotten at a call site.

Reference: [Supabase server-side auth for Next.js](https://supabase.com/docs/guides/auth/server-side/nextjs)
