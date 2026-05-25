---
title: Perform Auth Redirects at the Proxy, Not in Pages
impact: HIGH
impactDescription: prevents redirect duplication and double round-trips
tags: proxy, auth, redirect, boundary
---

## Perform Auth Redirects at the Proxy, Not in Pages

The proxy already handles "unauthenticated → /auth/sign-in" for `/home/*` and "authenticated → /home" for `/auth/*`. Pages downstream can assume the gate has been cleared. Adding the same redirect to a page or layout does the work twice (once at the proxy, again at render), creates ambiguous behavior when both fire, and forces every new protected route to remember the check. Decide routing once, at the boundary, before any React renders.

**Incorrect (redirect logic in the page server component):**

```tsx
// app/[locale]/home/(user)/settings/page.tsx
import { redirect } from 'next/navigation';
import { getServerClient } from '@app/supabase/server';

export default async function SettingsPage() {
  const client = getServerClient();
  const { data } = await client.auth.getClaims();

  if (!data?.claims) {
    // The proxy already did this. The check is now dead code that still pays
    // the auth round-trip on every authenticated request that reaches here.
    redirect('/auth/sign-in');
  }

  return <Settings userId={data.claims.sub} />;
}
```

**Correct (page assumes it is reachable only by authenticated users):**

```tsx
// app/[locale]/home/(user)/settings/page.tsx
import { requireUserInServerComponent } from '@app/supabase/require-user-server';

export default async function SettingsPage() {
  // The proxy already verified session + MFA. This returns the user;
  // it does NOT re-check whether they're allowed to be on this route.
  const user = await requireUserInServerComponent();

  return <Settings userId={user.id} />;
}
```

**The proxy's auth handlers live in one place** — a Supabase session check at the boundary:

```ts
// apps/web/proxy.ts
import { type NextRequest, NextResponse } from 'next/server';
import { getUserFromRequest } from '@app/supabase/proxy';

const authHandlers = [
  {
    pattern: new URLPattern({ pathname: '/home/*?' }),
    handler: async (request: NextRequest, response: NextResponse) => {
      const { data } = await getUserFromRequest(request, response);
      if (!data?.claims) {
        // Capture the origin path so post-sign-in returns the user here.
        const signIn = new URL('/auth/sign-in', request.nextUrl.origin);
        signIn.searchParams.set('next', request.nextUrl.pathname);
        return NextResponse.redirect(signIn.href);
      }
      // ... MFA assurance-level check ...
    },
  },
  {
    pattern: new URLPattern({ pathname: '/auth/*?' }),
    handler: async (request: NextRequest, response: NextResponse) => {
      const { data } = await getUserFromRequest(request, response);
      if (data?.claims) {
        // Logged-in user on an auth page → bounce home.
        return NextResponse.redirect(new URL('/home', request.nextUrl.origin).href);
      }
    },
  },
];
```

**What still belongs in the page:**

- **Resource-level authorization:** "can this user view *this specific* invoice?" — the data layer answers this (the scoped query returns nothing).
- **Feature-gating:** "is the account's plan high enough for this feature?" — a policy check, not session auth.
- **Conditional rendering:** "show the upgrade banner when `!hasActiveSubscription`" — UI logic, not redirect logic.

**Why the proxy is the right home:** it runs on every request and decides routing *before* any React rendering. A redirect from the proxy costs one round-trip; a redirect from a page render costs that round-trip plus the cost of starting (and discarding) the render.

*Transferable:* the principle is "gate routes once, at the request boundary." The session lookup shown here is Supabase; swap in any auth provider's request-side session read — the placement (in `proxy.ts`, not per page) is what matters.

Reference: [Next.js `proxy.ts` file convention](https://nextjs.org/docs/app/api-reference/file-conventions/proxy)
