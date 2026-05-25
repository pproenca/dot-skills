---
title: Enforce MFA at the Proxy Boundary, Not Per-Page
impact: CRITICAL
impactDescription: prevents MFA bypass on protected routes
tags: auth, mfa, proxy, middleware
---

## Enforce MFA at the Proxy Boundary, Not Per-Page

MFA enforcement is a request-boundary concern, not a page concern. In Next.js 16 the boundary lives in `proxy.ts` (the renamed `middleware.ts`, exporting `proxy` and running on the Node.js runtime). Check MFA there once for every request under `/home/*` and redirect to the verify path if the session has not cleared it. Re-implementing the check in individual pages or layouts means new routes are unprotected by default, and one missed copy-paste leaks a protected route to a half-authenticated session.

**Incorrect (MFA check copied into each protected page):**

```tsx
// app/[locale]/home/(user)/settings/page.tsx
export default async function SettingsPage() {
  const client = getServerClient();
  const requiresMfa = await checkRequiresMfa(client);

  if (requiresMfa) {
    redirect('/auth/verify');
  }
  // Now every protected page needs this block. A new page that forgets it
  // is silently accessible to half-authenticated sessions.
}
```

**Correct (one MFA gate in `proxy.ts` for `/home/*`):**

```ts
// apps/web/proxy.ts — runs at the request boundary before any page renders.
import { NextResponse, type NextRequest } from 'next/server';
import { createMiddlewareClient, getUser } from '@app/supabase/middleware';
import { checkRequiresMfa } from '@app/supabase/mfa';

export async function proxy(request: NextRequest) {
  const response = NextResponse.next();
  const url = new URL(request.url);
  if (!url.pathname.startsWith('/home')) return response;

  const { data } = await getUser(request, response);
  if (!data?.claims) {
    // Unauthenticated requests never reach the page at all.
    return NextResponse.redirect(new URL('/auth/sign-in', url.origin));
  }

  const client = createMiddlewareClient(request, response);
  if (await checkRequiresMfa(client)) {
    return NextResponse.redirect(new URL('/auth/verify', url.origin));
  }
  return response; // Pages under /home/* can trust the request cleared MFA.
}

export const config = { matcher: ['/home/:path*'] };
```

**The MFA verify page is the only exception.** It must render for users who have *not* yet cleared MFA, so it explicitly opts out (e.g. `requireUser(client, { verifyMfa: false })`) rather than redirecting them back to itself.

**Why this is more than a DRY argument:** centralizing the gate means there is one place to audit, one place to log, and one place that decides what counts as "needs MFA." If the policy changes (say, MFA required only after first sign-in), you update one function. With per-page checks, the audit surface scales with the number of routes.

**What still belongs in the page:** authorization for specific actions on a page ("can this user delete this project?") — that is per-route business logic, not session-level enforcement.

*Transferable:* "enforce session-level posture at the request boundary, not in leaf pages." The Supabase AAL/MFA check is the concrete example here; with any auth provider, do the step-up check once in `proxy.ts` so newly added routes inherit the gate instead of opting into it.

Reference: [Next.js proxy file convention](https://nextjs.org/docs/app/api-reference/file-conventions/proxy)
