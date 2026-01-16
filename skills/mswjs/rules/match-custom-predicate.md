---
title: Use Custom Predicates for Complex Matching
impact: MEDIUM-HIGH
impactDescription: Enables header-based, body-based, and conditional request matching
tags: match, predicate, custom, conditional, advanced
---

## Use Custom Predicates for Complex Matching

Use a predicate function instead of a URL string for complex matching logic. This enables matching based on headers, request body, cookies, or any combination of request properties.

**Incorrect (multiple handlers for same URL):**

```typescript
// Awkward - two handlers for same URL with different behavior
http.get('/api/data', () => {
  return HttpResponse.json({ public: true })
})

// How to handle authenticated vs unauthenticated?
```

**Correct (predicate-based matching):**

```typescript
import { http, HttpResponse } from 'msw'

export const handlers = [
  // Match based on header presence
  http.get('/api/data', ({ request }) => {
    const authHeader = request.headers.get('Authorization')

    if (authHeader?.startsWith('Bearer ')) {
      return HttpResponse.json({ data: 'authenticated content' })
    }

    return HttpResponse.json(
      { error: 'Unauthorized' },
      { status: 401 }
    )
  }),
]
```

**Predicate function syntax:**

```typescript
// Match by custom criteria
http.all(
  ({ request }) => {
    // Return true to match this request
    return request.url.includes('/api/') &&
           request.headers.get('X-Custom-Header') === 'special'
  },
  () => {
    return HttpResponse.json({ matched: true })
  }
)
```

**Match by request body content:**

```typescript
http.post(
  '/api/action',
  async ({ request }) => {
    const body = await request.clone().json()

    // Different response based on action type
    if (body.action === 'create') {
      return HttpResponse.json({ id: '1', created: true })
    }
    if (body.action === 'delete') {
      return new HttpResponse(null, { status: 204 })
    }

    return HttpResponse.json(
      { error: 'Unknown action' },
      { status: 400 }
    )
  }
)
```

**Match by cookie value:**

```typescript
http.get('/api/user', ({ cookies }) => {
  if (cookies.role === 'admin') {
    return HttpResponse.json({ permissions: ['read', 'write', 'delete'] })
  }
  return HttpResponse.json({ permissions: ['read'] })
})
```

**When NOT to use this pattern:**
- Simple URL-based matching is clearer when sufficient

Reference: [MSW Custom Request Predicate](https://mswjs.io/docs/best-practices/custom-request-predicate)
