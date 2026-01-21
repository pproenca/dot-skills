---
title: Match HTTP Methods Explicitly
impact: MEDIUM-HIGH
impactDescription: Prevents cross-method interference; models REST APIs correctly
tags: match, methods, http, get, post, put, delete
---

## Match HTTP Methods Explicitly

Use method-specific handlers (`http.get`, `http.post`, etc.) instead of `http.all`. This prevents a GET handler from accidentally matching POST requests and ensures correct REST API simulation.

**Incorrect (catching unintended methods):**

```typescript
// Matches ALL methods - GET, POST, PUT, DELETE, etc.
http.all('/api/user', () => {
  return HttpResponse.json({ name: 'John' })
})

// POST /api/user also returns user JSON instead of creating
```

**Correct (method-specific handlers):**

```typescript
import { http, HttpResponse } from 'msw'

export const handlers = [
  // GET - retrieve resource
  http.get('/api/user/:id', ({ params }) => {
    return HttpResponse.json({ id: params.id, name: 'John' })
  }),

  // POST - create resource
  http.post('/api/user', async ({ request }) => {
    const body = await request.json()
    return HttpResponse.json(
      { id: crypto.randomUUID(), ...body },
      { status: 201 }
    )
  }),

  // PUT - replace resource
  http.put('/api/user/:id', async ({ params, request }) => {
    const body = await request.json()
    return HttpResponse.json({ id: params.id, ...body })
  }),

  // PATCH - partial update
  http.patch('/api/user/:id', async ({ params, request }) => {
    const updates = await request.json()
    return HttpResponse.json({ id: params.id, name: 'John', ...updates })
  }),

  // DELETE - remove resource
  http.delete('/api/user/:id', () => {
    return new HttpResponse(null, { status: 204 })
  }),

  // HEAD - metadata only
  http.head('/api/user/:id', () => {
    return new HttpResponse(null, {
      headers: { 'X-User-Exists': 'true' },
    })
  }),

  // OPTIONS - CORS preflight
  http.options('/api/*', () => {
    return new HttpResponse(null, {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE',
      },
    })
  }),
]
```

**When to use http.all:**

```typescript
// Global middleware (logging, delay)
http.all('*', async () => {
  await delay(50)
  // No return - continues to next handler
})

// Catch-all fallback for testing
http.all('/api/*', () => {
  console.warn('Unhandled API request')
  return new HttpResponse(null, { status: 404 })
})
```

**When NOT to use this pattern:**
- Middleware handlers that should apply to all methods can use `http.all`

Reference: [MSW HTTP Handlers](https://mswjs.io/docs/api/http)
