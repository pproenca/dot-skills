---
title: Prefer Static Rendering by Default
impact: MEDIUM-HIGH
impactDescription: Static pages serve in 0-50ms from CDN edge; dynamic rendering adds 200-1000ms per request for server processing
tags: render, static, prerendering, CDN
---

## Prefer Static Rendering by Default

Static rendering generates HTML at build time, serving cached content from the CDN edge. This is the fastest possible response. Only opt into dynamic rendering when you need request-time data (cookies, headers, searchParams).

**Incorrect (accidentally dynamic):**

```typescript
// ❌ Accessing searchParams makes the entire page dynamic
export default async function ProductPage({
  params,
  searchParams,  // Just having this prop forces dynamic rendering
}: {
  params: Promise<{ id: string }>
  searchParams: Promise<{ [key: string]: string }>
}) {
  const { id } = await params
  const product = await getProduct(id)

  // searchParams never used, but page is still dynamic
  return <ProductDisplay product={product} />
}
```

```typescript
// ❌ Using headers() forces dynamic rendering
import { headers } from 'next/headers'

export default async function Page() {
  const headersList = await headers()  // Dynamic
  const userAgent = headersList.get('user-agent')

  // Could have been static if user-agent wasn't needed
  return <div>Welcome</div>
}
```

**Correct (static by design):**

```typescript
// ✓ No dynamic functions = static rendering
export default async function ProductPage({
  params,
}: {
  params: Promise<{ id: string }>
}) {
  const { id } = await params
  const product = await getProduct(id)

  return <ProductDisplay product={product} />
}

// Pre-generate all known products at build time
export async function generateStaticParams() {
  const products = await getAllProducts()
  return products.map(p => ({ id: p.id }))
}
```

**When dynamic rendering is appropriate:**

```typescript
// ✓ Dynamic because we NEED cookies for auth
import { cookies } from 'next/headers'

export default async function DashboardPage() {
  const cookieStore = await cookies()
  const session = cookieStore.get('session')

  if (!session) redirect('/login')

  const userData = await getUserData(session.value)
  return <Dashboard user={userData} />
}
```

**Dynamic triggers to be aware of:**
- `cookies()` - accessing cookies
- `headers()` - accessing request headers
- `searchParams` prop - URL query parameters
- `connection()` - explicitly opting into dynamic
- Uncached `fetch` - `cache: 'no-store'`

**Checking render mode:**

```bash
# Build output shows rendering mode
npm run build

# Look for:
# ○ (Static)   prerendered as static content
# ● (SSG)      prerendered as static HTML (uses generateStaticParams)
# λ (Dynamic)  server-rendered on demand
```

**When NOT to prefer static:**
- User-specific content (dashboards, personalized feeds)
- Real-time data requirements
- Authentication-dependent pages

Reference: [Next.js Static and Dynamic Rendering](https://nextjs.org/docs/app/building-your-application/rendering/server-components#static-rendering-default)
