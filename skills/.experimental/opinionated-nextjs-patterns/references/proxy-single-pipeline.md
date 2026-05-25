---
title: Compose the Whole Request Pipeline in One `proxy.ts`
impact: HIGH
impactDescription: prevents per-route request-handling drift
tags: proxy, request-pipeline, routing
---

## Compose the Whole Request Pipeline in One `proxy.ts`

Next.js runs one request-interception file per project — `proxy.ts`, whose exported `proxy` function runs on the Node.js runtime (Next.js 16 renamed `middleware.ts` to `proxy.ts`). Composing i18n routing, secure headers, correlation-ID propagation, URL-pattern matching, and the auth/MFA gates into a single ordered pipeline means every request is treated identically, in the same order, every time. There is only one interception point, so splitting concerns across imagined "per-route" files solves nothing — it adds indirection while making the ordering implicit and easy to break.

**Incorrect (fragmented helpers wired in unclear order):**

```ts
// proxy.ts
import type { NextRequest } from 'next/server';

export function proxy(request: NextRequest) {
  // What runs first? Auth on a request that should have been redirected by i18n?
  const localized = maybeI18nRoute(request);
  const gated = maybeAuthRedirect(request); // ignores `localized` — order is meaningless
  // Whoever edits this next has to rediscover the right order all over again.
  return maybeApplyHeaders(gated);
}
```

**Correct (one explicit, ordered pipeline):**

```ts
// apps/web/proxy.ts
import { type NextRequest, NextResponse } from 'next/server';

export async function proxy(request: NextRequest) {
  // 1. i18n routing first — every later step works against the localized response.
  const response = handleI18nRouting(request);

  // 2. Secure headers on top of the i18n response (no-op when STRICT_CSP is off).
  const securedResponse = await withSecureHeaders(response);

  // 3. Correlation ID for every request — read by the logger downstream.
  setCorrelationId(request);

  // 4. Pattern-matched handlers: /admin/*, /auth/*, /home/* — auth gates.
  const handler = await matchUrlPattern(request);
  if (handler) {
    const handled = await handler(request, securedResponse);
    if (handled) return handled;
  }

  // 5. Annotate server-action requests with their origin path.
  if (isServerActionRequest(request)) {
    securedResponse.headers.set('x-action-path', request.nextUrl.pathname);
  }

  return securedResponse;
}
```

**Why the order matters:**

| Step | If you move it later | Consequence |
|------|----------------------|-------------|
| i18n routing | After auth | Auth redirects to non-localized URLs that 404 |
| Secure headers | After pattern handlers | Pattern responses don't carry the CSP |
| `setCorrelationId` | After logging | Logs reference an ID that was never set |
| Pattern handlers | After the server-action header | Server-action requests skip the auth gate |

**Add to the pipeline, don't fork it.** A new concern (rate-limiting, geo-routing) becomes another numbered step in `proxy.ts`. Splitting it into a separate file would lose the explicit ordering the whole pipeline depends on.

**`config.matcher` excludes static assets and `api/*`.** Route handlers do their own auth in their own wrapper; the proxy doesn't run on them. Don't add API-shaped checks inside `proxy.ts` — wire those into the route-handler wrapper instead.

Reference: [Next.js `proxy.ts` file convention](https://nextjs.org/docs/app/api-reference/file-conventions/proxy)
