---
title: Avoid Accidentally Triggering Dynamic Rendering
impact: MEDIUM-HIGH
impactDescription: Unused dynamic APIs force server rendering on every request; removing them enables static caching at CDN edge
tags: render, dynamic, static, cookies, headers
---

## Avoid Accidentally Triggering Dynamic Rendering

Certain Next.js APIs automatically opt routes into dynamic rendering, even if you don't use their return values. Remove unused dynamic API calls to keep pages static and cacheable.

**Dynamic triggers to watch for:**

```typescript
// ❌ These make the entire route dynamic:
import { cookies, headers, connection } from 'next/headers'

cookies()         // Dynamic
headers()         // Dynamic
connection()      // Dynamic
searchParams prop // Dynamic
```

**Incorrect (accidentally dynamic):**

```typescript
// ❌ Route becomes dynamic even though cookies() result is unused
import { cookies } from 'next/headers'

export default async function ProductPage({ params }) {
  const { id } = await params
  const cookieStore = await cookies()  // Forces dynamic rendering

  // Cookie value never actually used
  const product = await getProduct(id)
  return <Product product={product} />
}
```

```typescript
// ❌ Having searchParams prop makes page dynamic
export default async function Page({
  params,
  searchParams,  // Dynamic trigger even if unused
}: {
  params: Promise<{ id: string }>
  searchParams: Promise<{ [key: string]: string }>
}) {
  const { id } = await params
  // searchParams never used
  return <div>{id}</div>
}
```

**Correct (intentionally static):**

```typescript
// ✓ No dynamic APIs = static rendering
export default async function ProductPage({
  params,
}: {
  params: Promise<{ id: string }>
}) {
  const { id } = await params
  const product = await getProduct(id)
  return <Product product={product} />
}

// Pre-generate product pages at build time
export async function generateStaticParams() {
  const products = await getAllProducts()
  return products.map(p => ({ id: p.id }))
}
```

**When dynamic IS needed:**

```typescript
// ✓ Using cookies for authentication - dynamic is appropriate
import { cookies } from 'next/headers'

export default async function DashboardPage() {
  const cookieStore = await cookies()
  const session = cookieStore.get('session')

  if (!session) {
    redirect('/login')
  }

  const user = await getUserFromSession(session.value)
  return <Dashboard user={user} />
}
```

**Check route rendering mode:**

```bash
# Build output shows rendering strategy
npm run build

# Legend:
# ○  Static   - prerendered as static content
# ●  SSG      - uses generateStaticParams
# λ  Dynamic  - server-rendered on demand
```

**Pattern: Isolate dynamic to specific components:**

```typescript
// Static page with dynamic island
import { Suspense } from 'react'

export default function ProductPage({ params }) {
  return (
    <div>
      <StaticProductInfo id={params.id} />  {/* Static */}
      <Suspense fallback={<CartCountSkeleton />}>
        <DynamicCartCount />  {/* Dynamic but isolated */}
      </Suspense>
    </div>
  )
}
```

**When NOT to avoid dynamic:**
- Page requires user-specific content
- Real-time data is essential
- Authentication/authorization checks needed

Reference: [Next.js Static and Dynamic Rendering](https://nextjs.org/docs/app/building-your-application/rendering/server-components#dynamic-rendering)
