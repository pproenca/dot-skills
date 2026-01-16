---
title: Use Middleware for Route Protection
impact: LOW-MEDIUM
impactDescription: Runs before every request at the edge; redirects unauthenticated users in <10ms without hitting your server
tags: advanced, middleware, auth, edge
---

## Use Middleware for Route Protection

Middleware runs at the edge before your page code executes. Use it for authentication checks, redirects, and request modifications. It's faster than checking auth in every page component.

**Incorrect (auth check in every page):**

```typescript
// ❌ Duplicated in every protected page
// app/dashboard/page.tsx
import { redirect } from 'next/navigation'
import { getSession } from '@/lib/auth'

export default async function DashboardPage() {
  const session = await getSession()

  if (!session) {
    redirect('/login')  // Runs after server component starts
  }

  return <Dashboard session={session} />
}

// app/settings/page.tsx
export default async function SettingsPage() {
  const session = await getSession()  // Same check duplicated

  if (!session) {
    redirect('/login')
  }

  return <Settings session={session} />
}
```

**Correct (centralized middleware):**

```typescript
// middleware.ts
import { NextRequest, NextResponse } from 'next/server'
import { decrypt } from '@/lib/session'

const protectedRoutes = ['/dashboard', '/settings', '/profile']
const publicRoutes = ['/login', '/register', '/']

export async function middleware(request: NextRequest) {
  const path = request.nextUrl.pathname
  const isProtected = protectedRoutes.some(route => path.startsWith(route))
  const isPublic = publicRoutes.includes(path)

  const cookie = request.cookies.get('session')?.value
  const session = await decrypt(cookie)

  // Redirect unauthenticated users from protected routes
  if (isProtected && !session?.userId) {
    return NextResponse.redirect(new URL('/login', request.url))
  }

  // Redirect authenticated users from public routes to dashboard
  if (isPublic && session?.userId && path !== '/') {
    return NextResponse.redirect(new URL('/dashboard', request.url))
  }

  return NextResponse.next()
}

export const config = {
  matcher: [
    // Skip static files and API routes
    '/((?!api|_next/static|_next/image|favicon.ico).*)',
  ],
}
```

**Middleware for geo-based routing:**

```typescript
// middleware.ts
import { NextRequest, NextResponse } from 'next/server'

export function middleware(request: NextRequest) {
  const country = request.geo?.country || 'US'

  // Redirect EU users to EU-specific page
  if (isEU(country) && request.nextUrl.pathname === '/') {
    return NextResponse.rewrite(new URL('/eu', request.url))
  }

  return NextResponse.next()
}

function isEU(country: string) {
  const euCountries = ['DE', 'FR', 'IT', 'ES', 'NL', /* ... */]
  return euCountries.includes(country)
}
```

**Adding headers:**

```typescript
export function middleware(request: NextRequest) {
  const response = NextResponse.next()

  // Add security headers
  response.headers.set('X-Frame-Options', 'DENY')
  response.headers.set('X-Content-Type-Options', 'nosniff')

  return response
}
```

**When NOT to use middleware:**
- Heavy computation (middleware should be fast)
- Database queries (use edge-compatible clients only)
- Complex business logic (keep in Server Components)

Reference: [Next.js Middleware](https://nextjs.org/docs/app/building-your-application/routing/middleware)
