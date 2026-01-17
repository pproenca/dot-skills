---
title: Use proxy.ts for Network Boundary Logic
impact: MEDIUM-HIGH
impactDescription: clearer network boundary, Node.js runtime
tags: route, proxy, middleware, network
---

## Use proxy.ts for Network Boundary Logic

Next.js 16 replaces `middleware.ts` with `proxy.ts` for explicit network boundary logic. The proxy runs on Node.js runtime (not Edge), providing access to full Node.js APIs.

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
