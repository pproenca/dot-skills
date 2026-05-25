---
title: Match Proxy Routes with `URLPattern`, Not String Comparisons
impact: MEDIUM-HIGH
impactDescription: prevents over-matching and trailing-slash misses
tags: proxy, routing, url-pattern, matcher
---

## Match Proxy Routes with `URLPattern`, Not String Comparisons

`URLPattern` matches the request URL structurally — `'/admin/*?'` matches `/admin`, `/admin/`, and `/admin/anything` but not `/administrators`. Naive `startsWith('/admin')` over-matches, so a future `/administrators` page is silently gated as admin; `endsWith`/exact equality misses trailing-slash variants. Pair `URLPattern` with a small pathname normalizer you own that strips the locale prefix, so `/en/admin` and `/admin` match the same pattern.

**Incorrect (string-prefix matching with classic edge cases):**

```ts
import type { NextRequest } from 'next/server';

function matchUrlPattern(request: NextRequest) {
  const pathname = request.nextUrl.pathname;

  // 1. Over-matches: a future /administrators route hits the admin handler.
  if (pathname.startsWith('/admin')) return adminHandler;

  // 2. Misses /auth (no trailing slash).
  if (pathname.startsWith('/auth/')) return authHandler;

  // 3. Locale-prefixed paths like /en/home never match /home/.
  if (pathname.startsWith('/home/')) return homeHandler;
}
```

**Correct (`URLPattern` + a normalized pathname):**

```ts
import type { NextRequest } from 'next/server';
import { stripLocalePrefix } from '@app/i18n/proxy';

async function getPatterns() {
  let Pattern = globalThis.URLPattern;
  if (!Pattern) {
    const { URLPattern } = await import('urlpattern-polyfill');
    Pattern = URLPattern as typeof Pattern;
  }

  return [
    {
      // '?' makes the trailing wildcard optional → matches /admin AND /admin/x.
      pattern: new Pattern({ pathname: '/admin/*?' }),
      handler: adminHandler,
    },
    { pattern: new Pattern({ pathname: '/auth/*?' }), handler: authHandler },
    { pattern: new Pattern({ pathname: '/home/*?' }), handler: homeHandler },
  ];
}

async function matchUrlPattern(request: NextRequest) {
  const patterns = await getPatterns();
  // Strip the locale prefix BEFORE matching: '/en/admin' → '/admin'.
  const input = stripLocalePrefix(request.nextUrl.pathname);

  for (const { pattern, handler } of patterns) {
    if (pattern.exec(input, request.nextUrl.origin)) {
      return handler;
    }
  }
}
```

**Why normalize first:** `URLPattern` matches the literal path; a locale prefix (`/en`, `/pt`) is not part of the routing concern, so strip it before matching. Otherwise every pattern has to enumerate every locale.

**`'/admin/*?'` vs `'/admin/*'`:** the `?` makes the wildcard optional. Without it, `/admin` (no trailing path) doesn't match; with it, both `/admin` and `/admin/foo` do.

**Polyfill fallback:** `URLPattern` is shipping in modern runtimes but isn't universal yet. The dynamic import of `urlpattern-polyfill` is only paid on runtimes that lack it.

**Don't put data fetching in the matcher.** The matcher's only job is to decide *which handler runs*; that handler can then read the session. Mixing the two means every URL parse hits the network.

Reference: [Next.js `proxy.ts` file convention](https://nextjs.org/docs/app/api-reference/file-conventions/proxy)
