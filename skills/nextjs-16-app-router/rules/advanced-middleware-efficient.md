---
title: Keep Middleware Fast and Lightweight
impact: LOW
impactDescription: Reduces TTFB by 10-50ms per request by avoiding blocking operations
tags: advanced, middleware, performance, edge-runtime
---

## Keep Middleware Fast and Lightweight

Middleware runs on every matching request before the page renders. Heavy computations, database calls, or complex logic in middleware block the entire request, adding latency to Time to First Byte. Keep middleware focused on lightweight tasks like redirects, rewrites, and header modifications.

**Incorrect (heavy computation in middleware):**

```typescript
// middleware.ts
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export async function middleware(request: NextRequest) {
  // Database call blocks every request - adds 50-200ms latency
  const user = await fetch(`${process.env.API_URL}/users/verify`, {
    headers: { cookie: request.headers.get('cookie') || '' },
  }).then((res) => res.json())

  const permissions = await fetch(`${process.env.API_URL}/permissions/${user.id}`)
    .then((res) => res.json())

  if (!permissions.canAccess) {
    return NextResponse.redirect(new URL('/unauthorized', request.url))
  }

  return NextResponse.next()
}
```

**Correct (lightweight token check with deferred verification):**

```typescript
// middleware.ts
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export async function middleware(request: NextRequest) {
  const sessionToken = request.cookies.get('session')?.value

  if (!sessionToken) {
    return NextResponse.redirect(new URL('/login', request.url))
  }

  // Pass token to page for full verification - no blocking fetch
  const requestHeaders = new Headers(request.headers)
  requestHeaders.set('x-session-token', sessionToken)

  return NextResponse.next({
    request: { headers: requestHeaders },
  })
}
```

**What middleware should do:**
- Check for presence of auth tokens (not validate them)
- Redirect based on simple conditions (locale, feature flags)
- Set headers or rewrite URLs
- Rate limiting with edge-compatible stores

**What middleware should NOT do:**
- Database queries or API calls that block rendering
- Complex data transformations
- Session validation (defer to route handlers)
- Heavy cryptographic operations

Reference: [Next.js Middleware](https://nextjs.org/docs/app/building-your-application/routing/middleware)
