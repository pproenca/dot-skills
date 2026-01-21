---
title: Use URL Path Parameters Correctly
impact: MEDIUM-HIGH
impactDescription: Prevents silent handler mismatches; enables dynamic URL matching
tags: match, url, params, path-parameters, dynamic
---

## Use URL Path Parameters Correctly

Use `:paramName` syntax for dynamic path segments. Parameters are available in the resolver's `params` object. Incorrect patterns cause handlers to never match.

**Incorrect (literal URL instead of pattern):**

```typescript
// Only matches exact string "/api/user/123"
http.get('/api/user/123', () => {
  return HttpResponse.json({ name: 'John' })
})

// Request to /api/user/456 is unhandled
```

**Correct (parameterized URL):**

```typescript
import { http, HttpResponse } from 'msw'

export const handlers = [
  // Matches /api/user/123, /api/user/abc, etc.
  http.get('/api/user/:id', ({ params }) => {
    return HttpResponse.json({ id: params.id, name: 'John' })
  }),

  // Multiple parameters
  http.get('/api/org/:orgId/user/:userId', ({ params }) => {
    return HttpResponse.json({
      orgId: params.orgId,
      userId: params.userId,
    })
  }),

  // Optional parameters (use separate handlers)
  http.get('/api/posts', () => {
    return HttpResponse.json([{ id: '1' }, { id: '2' }])
  }),
  http.get('/api/posts/:postId', ({ params }) => {
    return HttpResponse.json({ id: params.postId })
  }),
]
```

**Wildcard patterns:**

```typescript
// Match any path starting with /api/
http.get('/api/*', () => {
  return HttpResponse.json({ fallback: true })
})

// Match any origin with specific path
http.get('*/api/user', () => {
  return HttpResponse.json({ name: 'John' })
})

// Match all requests of a method
http.get('*', () => {
  return HttpResponse.json({ catchAll: true })
})
```

**Type-safe parameters:**

```typescript
type UserParams = {
  userId: string
}

http.get<UserParams>('/api/user/:userId', ({ params }) => {
  // params.userId is typed as string
  return HttpResponse.json({ id: params.userId })
})
```

**When NOT to use this pattern:**
- Exact URL matching for specific endpoints that never vary

Reference: [MSW Request Matching](https://mswjs.io/docs/http/intercepting-requests)
