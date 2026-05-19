---
title: Use `requireUser()` Instead of Raw `client.auth.getClaims()`
impact: CRITICAL
impactDescription: prevents skipping the MFA verification gate
tags: auth, mfa, require-user, redirect
---

## Use `requireUser()` Instead of Raw `client.auth.getClaims()`

`requireUser()` from `@kit/supabase/require-user` does three things atomically: validates the JWT, checks whether MFA is required for this account, and returns the correct `redirectTo` URL for whichever check failed. Calling `client.auth.getClaims()` directly skips the MFA branch — a user with MFA enabled but only AAL1 in their JWT will pass the claim check and gain access to protected pages.

**Incorrect (manual claims check — skips MFA):**

```ts
const client = getSupabaseServerClient();
const { data, error } = await client.auth.getClaims();

if (!data?.claims || error) {
  redirect('/auth/sign-in');
}

// data.claims.aal might be 'aal1' even though the user has MFA enrolled —
// this loader now serves protected data to a half-authenticated session.
const userId = data.claims.sub;
```

**Correct (delegate to `requireUser` — discriminated union return):**

```ts
import { requireUser } from '@kit/supabase/require-user';

const client = getSupabaseServerClient();
const auth = await requireUser(client);

if (auth.error) {
  // redirectTo points to /auth/sign-in OR /auth/verify as appropriate
  redirect(auth.redirectTo);
}

// auth.data is typed as JWTUserData — id, email, is_superadmin, aal, etc.
const userId = auth.data.id;
```

**Why the discriminated union matters:** the TypeScript narrowing forces you to handle the error case before reading `auth.data`. There is no way to silently use a stale or missing user.

**`verifyMfa: false` only when you have a reason:** the MFA verify page itself calls `requireUser(client, { verifyMfa: false })` because it *is* the destination. Outside that page, the default `true` is what you want.

**Pair this with the middleware MFA gate.** See `auth-mfa-in-middleware` — MFA enforcement happens at the request boundary in `proxy.ts`. `requireUser()` is the per-context helper that produces the right redirect target; the middleware does the redirect for `/home/*` requests before any page renders.

**Where to call it:**

| Context | Pattern |
|---------|---------|
| Server Component / loader | `requireUserInServerComponent()` (wraps `requireUser`, handles redirect) |
| Server Action | Use `authActionClient` — it calls `requireUser` and injects `ctx.user` |
| Route Handler | Use `enhanceRouteHandler` — `auth: true` calls `requireUser` |
| Webhook | `auth: false` — no user; verify a signature instead |

Reference: [Makerkit auth helpers](https://makerkit.dev/docs/next-supabase-turbo/authentication/auth-server-helpers)
