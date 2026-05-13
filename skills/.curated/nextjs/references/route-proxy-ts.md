---
title: Network-boundary logic (auth, redirects, header rewrites) lives in `proxy.ts` — not the deprecated `middleware.ts`
impact: MEDIUM-HIGH
impactDescription: aligns with Next.js 16 runtime model (Node.js, not Edge), enables full Node API access for the proxy layer
tags: route, proxy-ts, network-boundary, middleware-migration
---

## Network-boundary logic (auth, redirects, header rewrites) lives in `proxy.ts` — not the deprecated `middleware.ts`

**Pattern intent:** Next.js 16 renamed and re-runtimed the network boundary: `middleware.ts` (Edge runtime) → `proxy.ts` (Node.js runtime). Code at the network boundary now has full Node access; the file name and the exported function name both change.

### Shapes to recognize

- A `middleware.ts` file in a Next.js 16 codebase — works during a transition period, but the supported path is `proxy.ts`.
- An exported `function middleware(...)` — same migration concern.
- Edge-runtime-specific imports (`@edge-runtime/...`) left over from the old constraint — usually now unnecessary.
- An auth check in `middleware.ts` calling a service that requires Node-native APIs (e.g., Prisma client) — was a hack to dodge Edge constraints; can be simplified now in `proxy.ts`.
- A pattern of "use middleware for auth, use route handlers for everything else" — `proxy.ts` can do more (request rewrites, response header injection, redirects) without splitting into separate files.

The canonical resolution: rename `middleware.ts` → `proxy.ts`, rename the exported `middleware` function → `proxy`. Keep the `config.matcher`. Remove any Edge-runtime workarounds.

Reference: [Next.js 16 proxy.ts](https://nextjs.org/docs/app/building-your-application/routing/middleware)

**Incorrect (old middleware.ts pattern):**

```typescript
// middleware.ts (deprecated in Next.js 16)
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export function middleware(request: NextRequest) {
  const token = request.cookies.get('token')
  if (!token) {
    return NextResponse.redirect(new URL('/login', request.url))
  }
}

export const config = {
  matcher: '/dashboard/:path*'
}
```

**Correct (proxy.ts in Next.js 16):**

```typescript
// proxy.ts
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export function proxy(request: NextRequest) {
  const token = request.cookies.get('token')

  // Full Node.js APIs available (not Edge)
  if (!token) {
    return NextResponse.redirect(new URL('/login', request.url))
  }

  // Add headers, rewrite, etc.
  const response = NextResponse.next()
  response.headers.set('x-custom-header', 'value')
  return response
}

export const config = {
  matcher: '/dashboard/:path*'
}
```

**Migration:**
1. Rename `middleware.ts` → `proxy.ts`
2. Rename exported function `middleware` → `proxy`
3. Update any Edge-specific code to use Node.js APIs

Reference: [Next.js 16 proxy.ts](https://nextjs.org/docs/app/building-your-application/routing/middleware)
