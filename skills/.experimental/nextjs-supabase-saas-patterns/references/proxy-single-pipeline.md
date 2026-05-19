---
title: Compose the Request Pipeline in One `proxy.ts`
impact: HIGH
impactDescription: prevents per-route middleware drift
tags: proxy, middleware, request-pipeline, edge
---

## Compose the Request Pipeline in One `proxy.ts`

Next.js runs one middleware file per project (the kit calls it `proxy.ts`). Composing i18n routing, secure headers, request-ID propagation, URL-pattern matching, and the auth/MFA/admin gates into a single ordered pipeline means every request is treated identically, in the same order, every time. Splitting concerns across imagined "per-route middlewares" doesn't work — there is only one middleware, so every split adds a layer of indirection without solving anything, and the ordering becomes implicit and easy to break.

**Incorrect (fragmented helpers wired by one file but in unclear order):**

```ts
// proxy.ts
export default async function proxy(req: NextRequest) {
  // What runs first? Auth on a request that should have been redirected by i18n?
  const r1 = await maybeAuthRedirect(req);
  const r2 = await maybeI18nRoute(req);
  const r3 = await maybeApplyHeaders(req);
  // Whoever edits this next has to figure out the right order all over again.
  return r3;
}
```

**Correct (the kit's actual pipeline, explicit and ordered):**

```ts
// apps/web/proxy.ts
export default async function proxy(request: NextRequest) {
  // 1. i18n routing first — every later step works against the i18n response.
  const response = handleI18nRouting(request);

  // 2. Secure headers on top of the i18n response (no-op if STRICT_CSP off).
  const secureHeadersResponse = await createResponseWithSecureHeaders(response);

  // 3. Correlation ID for every request — read by getLogger() downstream.
  setRequestId(request);

  // 4. Pattern-matched handlers: /admin/*, /auth/*, /home/* — auth gates.
  const handlePattern = await matchUrlPattern(request);
  if (handlePattern) {
    const patternResponse = await handlePattern(request, secureHeadersResponse);
    if (patternResponse) return patternResponse;
  }

  // 5. Annotate server-action requests with their origin path.
  if (isServerAction(request)) {
    secureHeadersResponse.headers.set('x-action-path', request.nextUrl.pathname);
  }

  return secureHeadersResponse;
}
```

**Why the order matters:**

| Step | If you move it later | Consequence |
|------|---------------------|-------------|
| i18n routing | After auth | Auth redirects to non-localized URLs that 404 |
| Secure headers | After pattern handlers | Pattern responses don't carry CSP |
| `setRequestId` | After logging | Logs reference a request ID that's never set |
| Pattern handlers | After server-action header | Server-action requests skip auth |

**Add to the pipeline, don't fork it.** A new concern (e.g., rate-limiting) becomes another step in `proxy.ts`. Splitting it into a separate file would lose the explicit ordering this pipeline depends on.

**`config.matcher` excludes static assets and `api/*`.** API routes handle their own auth via `enhanceRouteHandler`; the proxy doesn't run on them. Don't add API-shaped checks inside `proxy.ts` — wire them into the route handler wrapper.

Reference: [Next.js middleware](https://nextjs.org/docs/app/building-your-application/routing/middleware)
