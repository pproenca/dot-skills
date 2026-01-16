---
title: Avoid Blocking Root Layout with Async Operations
impact: CRITICAL
impactDescription: Root layout blocking delays entire application shell; users see nothing until slowest operation completes
tags: async, layout, blocking, performance
---

## Avoid Blocking Root Layout with Async Operations

Async operations in root layout block the entire page shell from rendering. Move slow fetches to page components or nested layouts where they only affect their specific route segment.

**Incorrect (blocking root layout):**

```typescript
// app/layout.tsx
export default async function RootLayout({ children }) {
  // ❌ These block EVERYTHING
  const user = await getUser()        // 200ms
  const settings = await getSettings() // 150ms
  const notifications = await getNotifications() // 300ms
  // Total: 650ms before ANY content appears

  return (
    <html>
      <body>
        <Header user={user} notifications={notifications} />
        {children}
        <Footer settings={settings} />
      </body>
    </html>
  )
}
```

**Correct (non-blocking layout):**

```typescript
// app/layout.tsx
import { Suspense } from 'react'

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        <Suspense fallback={<HeaderSkeleton />}>
          <Header />
        </Suspense>
        {children}
        <Footer />
      </body>
    </html>
  )
}

// components/Header.tsx
async function Header() {
  const [user, notifications] = await Promise.all([
    getUser(),
    getNotifications(),
  ])
  return <header>{/* ... */}</header>
}

// components/Footer.tsx
async function Footer() {
  const settings = await getSettings()
  return <footer>{/* ... */}</footer>
}
```

**Alternative: Move auth to middleware:**

```typescript
// middleware.ts
export async function middleware(request: NextRequest) {
  const session = await getSession(request)

  // Set user info in headers for downstream consumption
  const response = NextResponse.next()
  if (session) {
    response.headers.set('x-user-id', session.userId)
  }
  return response
}
```

```typescript
// app/layout.tsx - Synchronous, fast
import { headers } from 'next/headers'

export default async function RootLayout({ children }) {
  const headersList = await headers()
  const userId = headersList.get('x-user-id')

  return (
    <html>
      <body>
        <Header userId={userId} />
        {children}
      </body>
    </html>
  )
}
```

**When NOT to avoid root layout fetches:**
- Data is critical and fast (<50ms)
- Using cached data that's already warm
- Intentionally blocking for auth redirects

Reference: [Next.js Layouts](https://nextjs.org/docs/app/building-your-application/routing/layouts-and-templates)
