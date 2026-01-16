---
title: Use Route Handlers for API Endpoints
impact: LOW-MEDIUM
impactDescription: Native HTTP handling with full request/response control; co-located with app structure
tags: advanced, api, route-handlers, REST
---

## Use Route Handlers for API Endpoints

Route Handlers in the App Router replace API routes from the pages directory. They support all HTTP methods and integrate with Next.js caching and streaming.

**Basic route handler:**

```typescript
// app/api/products/route.ts
import { NextResponse } from 'next/server'

export async function GET() {
  const products = await getProducts()
  return NextResponse.json(products)
}

export async function POST(request: Request) {
  const data = await request.json()
  const product = await createProduct(data)
  return NextResponse.json(product, { status: 201 })
}
```

**Dynamic route handlers:**

```typescript
// app/api/products/[id]/route.ts
import { NextResponse } from 'next/server'
import { notFound } from 'next/navigation'

export async function GET(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params
  const product = await getProduct(id)

  if (!product) {
    return NextResponse.json({ error: 'Not found' }, { status: 404 })
  }

  return NextResponse.json(product)
}

export async function PUT(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params
  const data = await request.json()
  const product = await updateProduct(id, data)
  return NextResponse.json(product)
}

export async function DELETE(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params
  await deleteProduct(id)
  return new Response(null, { status: 204 })
}
```

**Caching route handlers:**

```typescript
// Cached by default for GET without dynamic functions
export async function GET() {
  const data = await fetch('https://api.example.com/data', {
    next: { revalidate: 3600 }
  })
  return NextResponse.json(await data.json())
}

// Opt out of caching
export const dynamic = 'force-dynamic'

export async function GET() {
  // Always fresh
}
```

**Streaming responses:**

```typescript
export async function GET() {
  const encoder = new TextEncoder()

  const stream = new ReadableStream({
    async start(controller) {
      for await (const chunk of generateData()) {
        controller.enqueue(encoder.encode(JSON.stringify(chunk) + '\n'))
      }
      controller.close()
    }
  })

  return new Response(stream, {
    headers: { 'Content-Type': 'application/x-ndjson' }
  })
}
```

**CORS handling:**

```typescript
export async function GET(request: Request) {
  const data = await getData()

  return NextResponse.json(data, {
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    }
  })
}

export async function OPTIONS() {
  return new Response(null, {
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
    }
  })
}
```

**When NOT to use route handlers:**
- Server Actions are sufficient (mutations from components)
- External API proxy (use middleware or rewrites)
- Simple data fetching (use Server Components)

Reference: [Next.js Route Handlers](https://nextjs.org/docs/app/building-your-application/routing/route-handlers)
