---
title: Order Handlers from Specific to General
impact: MEDIUM-HIGH
impactDescription: Prevents general handlers from shadowing specific ones
tags: match, order, priority, specific, general
---

## Order Handlers from Specific to General

Place more specific handlers before general ones in the handlers array. MSW matches handlers in order, and the first match wins. A wildcard handler placed first will shadow all subsequent handlers.

**Incorrect (general handler shadows specific):**

```typescript
export const handlers = [
  // Wildcard matches first - specific handlers never reached!
  http.get('/api/*', () => {
    return HttpResponse.json({ fallback: true })
  }),

  // Never matches because /api/* already caught it
  http.get('/api/user/:id', ({ params }) => {
    return HttpResponse.json({ id: params.id, name: 'John' })
  }),
]
```

**Correct (specific before general):**

```typescript
import { http, HttpResponse } from 'msw'

export const handlers = [
  // Most specific handlers first
  http.get('/api/user/:id/settings', ({ params }) => {
    return HttpResponse.json({ userId: params.id, theme: 'dark' })
  }),

  http.get('/api/user/:id', ({ params }) => {
    return HttpResponse.json({ id: params.id, name: 'John' })
  }),

  http.get('/api/users', () => {
    return HttpResponse.json([{ id: '1' }, { id: '2' }])
  }),

  // General fallback last
  http.get('/api/*', () => {
    return HttpResponse.json(
      { error: 'Not found' },
      { status: 404 }
    )
  }),
]
```

**Middleware with passthrough:**

```typescript
export const handlers = [
  // Middleware runs first but doesn't return - passes through
  http.all('*', async () => {
    await delay(50)  // Add delay to all requests
    // No return = continue to next handler
  }),

  // Specific handlers still match
  http.get('/api/user', () => {
    return HttpResponse.json({ name: 'John' })
  }),
]
```

**Runtime handler precedence:**

```typescript
// Initial handlers
const server = setupServer(
  http.get('/api/user', () => HttpResponse.json({ name: 'John' }))
)

// Runtime handlers are PREPENDED (take precedence)
server.use(
  http.get('/api/user', () => HttpResponse.json({ name: 'Jane' }))
)

// Request to /api/user returns { name: 'Jane' }
```

**When NOT to use this pattern:**
- Single handlers don't have ordering concerns

Reference: [MSW Handler Precedence](https://mswjs.io/docs/concepts/request-handler)
