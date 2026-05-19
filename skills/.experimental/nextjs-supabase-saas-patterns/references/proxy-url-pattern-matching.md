---
title: Match Middleware Routes with `URLPattern`, Not String Comparisons
impact: MEDIUM-HIGH
impactDescription: prevents over-matching and trailing-slash misses
tags: proxy, routing, url-pattern, matcher
---

## Match Middleware Routes with `URLPattern`, Not String Comparisons

`URLPattern` matches the request URL structurally — `'/admin/*?'` matches `/admin`, `/admin/`, and `/admin/anything` but not `/administrators`. Naive `startsWith('/admin')` over-matches (a future `/administrators` page is silently gated as admin); endsWith / exact equality misses trailing-slash variants. URLPattern also pairs cleanly with the kit's `getNormalizedPathname` helper that strips the locale prefix so `/en/admin` and `/admin` match the same pattern.

**Incorrect (string-prefix matching with classic edge cases):**

```ts
async function matchUrlPattern(request: NextRequest) {
  const pathname = request.nextUrl.pathname;

  // 1. Over-matches: /administrators routes accidentally hit the admin handler.
  if (pathname.startsWith('/admin')) return adminMiddleware;

  // 2. Misses /auth (no trailing /).
  if (pathname.startsWith('/auth/')) return authMiddleware;

  // 3. Locale-prefixed paths like /en/home don't match /home/.
  if (pathname.startsWith('/home/')) return homeMiddleware;
}
```

**Correct (URLPattern + normalised pathname):**

```ts
async function getPatterns() {
  let URLPattern = globalThis.URLPattern;
  if (!URLPattern) {
    const { URLPattern: polyfill } = await import('urlpattern-polyfill');
    URLPattern = polyfill as typeof URLPattern;
  }

  return [
    {
      // '?' makes the trailing wildcard optional → matches /admin AND /admin/x.
      pattern: new URLPattern({ pathname: '/admin/*?' }),
      handler: adminMiddleware,
    },
    {
      pattern: new URLPattern({ pathname: '/auth/*?' }),
      handler: authHandler,
    },
    {
      pattern: new URLPattern({ pathname: '/home/*?' }),
      handler: homeHandler,
    },
  ];
}

async function matchUrlPattern(request: NextRequest) {
  const patterns = await getPatterns();
  // Strip the locale prefix BEFORE matching: '/en/admin' → '/admin'.
  const input = getNormalizedPathname(request.nextUrl.pathname);

  for (const { pattern, handler } of patterns) {
    const result = pattern.exec(input, request.nextUrl.origin);
    if (result !== null && 'pathname' in result) {
      return handler;
    }
  }
}
```

**Why normalize the pathname first:** `URLPattern` matches the literal path; the locale prefix (`/en`, `/pt`) is not part of the routing concern, so strip it before matching. Otherwise every pattern needs to enumerate every locale.

**`'/admin/*?'` vs `'/admin/*'`:** the `?` makes the wildcard optional. Without it, `/admin` (no trailing path) doesn't match. With it, both `/admin` and `/admin/foo` are matched.

**Polyfill fallback:** `URLPattern` is shipping in edge runtimes but isn't universal yet. The dynamic import of `urlpattern-polyfill` is only paid on runtimes that need it.

**Don't put database queries in the matcher.** The matcher's job is to decide *which handler runs* — that handler can then call Supabase. Mixing the two means every URL parse hits the network.

Reference: [URLPattern API](https://developer.mozilla.org/en-US/docs/Web/API/URLPattern)
