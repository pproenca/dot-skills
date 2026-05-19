---
title: Perform Auth Redirects at the Middleware, Not in Pages
impact: HIGH
impactDescription: prevents redirect duplication and double round-trips
tags: proxy, auth, redirect, boundary
---

## Perform Auth Redirects at the Middleware, Not in Pages

The proxy already handles "unauthenticated → /auth/sign-in" for `/home/*` and "authenticated → /home" for `/auth/*`. Pages downstream can assume the gate has been cleared. Adding the same redirect to a page or layout causes the work to happen twice (once at middleware, again at page render), creates ambiguous behavior when both fire (which one wins?), and means every new protected route has to remember to add the check.

**Incorrect (redirect logic in the page server component):**

```tsx
// app/[locale]/home/(user)/settings/page.tsx
export default async function SettingsPage() {
  const client = getSupabaseServerClient();
  const { data } = await client.auth.getClaims();

  if (!data?.claims) {
    // The proxy already did this. Now we do it again.
    // First request: proxy redirects to /auth/sign-in.
    // After sign-in, this page renders — the check is dead code but still pays
    // the Supabase round-trip cost on every request.
    redirect('/auth/sign-in');
  }

  return <Settings userId={data.claims.sub} />;
}
```

**Correct (page assumes it is reachable only by authenticated users):**

```tsx
// app/[locale]/home/(user)/settings/page.tsx
import { requireUserInServerComponent } from '~/lib/server/require-user-in-server-component';

export default async function SettingsPage() {
  // Proxy already verified auth + MFA. This call returns the user;
  // it does NOT re-check whether they're allowed to be here.
  const user = await requireUserInServerComponent();

  return <Settings userId={user.id} />;
}
```

**Where the proxy's auth handlers live:**

```ts
// apps/web/proxy.ts (the shipped handlers)
{
  pattern: new URLPattern({ pathname: '/home/*?' }),
  handler: async (req, res) => {
    const { data } = await getUser(req, res);
    if (!data?.claims) {
      // Capture the original path so post-sign-in redirect returns here.
      return NextResponse.redirect(
        new URL(`${pathsConfig.auth.signIn}?next=${req.nextUrl.pathname}`, req.nextUrl.origin).href,
      );
    }
    // ... MFA check ...
  },
},
{
  pattern: new URLPattern({ pathname: '/auth/*?' }),
  handler: async (req, res) => {
    const { data } = await getUser(req, res);
    if (data?.claims && !isVerifyMfa) {
      // Logged-in user on auth pages → bounce home.
      return NextResponse.redirect(new URL(pathsConfig.app.home, req.nextUrl.origin).href);
    }
  },
},
```

**What still belongs in the page:**

- **Resource-level authorization:** "can this user view *this specific* invoice?" — RLS answers this for you (the query returns nothing).
- **Feature-gating:** "is the team's plan high enough to use this feature?" — that's a policy check, not session auth.
- **Conditional rendering:** "show the upgrade banner if `!hasActiveSubscription`" — UI logic, not redirect logic.

**Why the proxy is the right home:** it runs on every request, on the edge runtime, and decides routing *before* any React rendering happens. A redirect from middleware costs one round-trip; a redirect from a page render costs that round-trip plus the cost of starting (and discarding) the page render.

Reference: [Next.js middleware redirects](https://nextjs.org/docs/app/building-your-application/routing/middleware#nextresponse)
