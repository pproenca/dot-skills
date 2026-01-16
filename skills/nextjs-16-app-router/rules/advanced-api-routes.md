---
title: Use Route Handlers with Proper Caching
impact: LOW
impactDescription: Enables edge caching for API responses and reduces server load
tags: advanced, api, route-handlers, caching
---

## Use Route Handlers with Proper Caching

Route Handlers without caching configuration regenerate responses on every request, increasing server load and response times. Using the `dynamic` export and cache headers enables edge caching for appropriate endpoints, reducing latency and server costs.

**Incorrect (no caching - regenerates every request):**

```typescript
// app/api/products/route.ts
import { NextResponse } from 'next/server'

export async function GET() {
  const products = await db.products.findMany()
  // Runs database query on every request - no caching
  return NextResponse.json(products)
}
```

**Correct (cached with revalidation):**

```typescript
// app/api/products/route.ts
import { NextResponse } from 'next/server'

export const dynamic = 'force-static'
export const revalidate = 3600 // Cache for 1 hour

export async function GET() {
  const products = await db.products.findMany()

  return NextResponse.json(products, {
    headers: {
      'Cache-Control': 'public, s-maxage=3600, stale-while-revalidate=86400',
    },
  })
}
```

**Alternative (dynamic routes with request-based caching):**

```typescript
// app/api/products/[category]/route.ts
import { NextRequest, NextResponse } from 'next/server'

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ category: string }> }
) {
  const { category } = await params
  const products = await db.products.findMany({
    where: { category },
  })

  return NextResponse.json(products, {
    headers: {
      'Cache-Control': 'public, s-maxage=600, stale-while-revalidate=1200',
    },
  })
}
```

**Caching strategies by endpoint type:**

| Endpoint Type | Strategy |
|---------------|----------|
| Static data (categories, config) | `force-static` with long revalidate |
| Semi-dynamic (product lists) | Short revalidate (5-60 min) |
| User-specific data | `force-dynamic`, no cache |
| Real-time data | `force-dynamic` with streaming |

**When NOT to cache:**
- User-specific or authenticated responses
- Data that must be real-time accurate
- POST/PUT/DELETE mutations

Reference: [Route Handlers](https://nextjs.org/docs/app/building-your-application/routing/route-handlers)
