---
title: Enforce MFA at the Middleware, Not Per-Page
impact: CRITICAL
impactDescription: prevents MFA bypass on protected routes
tags: auth, mfa, middleware, proxy
---

## Enforce MFA at the Middleware, Not Per-Page

MFA enforcement is a request-boundary concern, not a page concern. `proxy.ts` already calls `checkRequiresMultiFactorAuthentication()` for every request matching `/home/*` and redirects to the verify path if needed. Re-implementing the check in individual pages or layouts means new routes are unprotected by default, and one missed copy-paste leaks a protected route to AAL1 sessions.

**Incorrect (MFA check copied into each protected page):**

```tsx
// app/[locale]/home/(user)/settings/page.tsx
export default async function SettingsPage() {
  const client = getSupabaseServerClient();
  const requiresMfa = await checkRequiresMultiFactorAuthentication(client);

  if (requiresMfa) {
    redirect('/auth/verify');
  }
  // ...
}

// Now every protected page needs this block. A new page that forgets it
// is silently accessible to half-authenticated sessions.
```

**Correct (one MFA gate in the proxy for `/home/*`):**

```ts
// apps/web/proxy.ts (the actual pattern shipped in the kit)
{
  pattern: new URLPattern({ pathname: '/home/*?' }),
  handler: async (req, res) => {
    const { data } = await getUser(req, res);
    if (!data?.claims) {
      return NextResponse.redirect(new URL(`${signIn}?next=${next}`, origin).href);
    }

    const supabase = createMiddlewareClient(req, res);
    const requiresMfa = await checkRequiresMultiFactorAuthentication(supabase);

    if (requiresMfa) {
      return NextResponse.redirect(new URL(pathsConfig.auth.verifyMfa, origin).href);
    }
  },
},

// Pages and layouts under /home/* can now trust that requests reaching
// them have already passed the MFA gate.
```

**The MFA verify page is the only exception.** It needs to render for users who have *not* yet cleared MFA, so it explicitly opts out via `requireUser(client, { verifyMfa: false })`.

**Why this is more than a DRY argument:** centralizing the gate means there is one place to audit, one place to log, and one place that decides what counts as "needs MFA." If the policy changes (e.g., MFA required only after first sign-in), you update one function. With per-page checks, the audit surface scales with the number of routes.

**What still belongs in the page:** authorization for specific actions on a page (e.g., "can this user delete this project?") — that is per-route business logic, not session-level enforcement.

Reference: [Makerkit MFA flow](https://makerkit.dev/docs/next-supabase-turbo/authentication/multi-factor-authentication)
