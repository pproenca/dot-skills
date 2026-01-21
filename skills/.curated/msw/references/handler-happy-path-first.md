---
title: Define Happy Path Handlers as Baseline
impact: CRITICAL
impactDescription: Establishes reliable baseline; enables clean runtime overrides
tags: handler, structure, happy-path, baseline, organization
---

## Define Happy Path Handlers as Baseline

Define success-state handlers in a central `handlers.ts` file as your baseline. This establishes a reliable foundation that runtime overrides can modify for error scenarios, keeping test-specific edge cases separate from normal behavior.

**Incorrect (mixing success and error states):**

```typescript
// mocks/handlers.ts - cluttered with all scenarios
export const handlers = [
  http.get('/user', () => HttpResponse.json({ name: 'John' })),
  http.get('/user', () => new HttpResponse(null, { status: 401 })),
  http.get('/user', () => new HttpResponse(null, { status: 500 })),
  http.get('/user', () => HttpResponse.error()),
  // Confusing: which handler runs? Last one wins but intent unclear
]
```

**Correct (happy path baseline with runtime overrides):**

```typescript
// mocks/handlers.ts - clean success states only
import { http, HttpResponse } from 'msw'

export const handlers = [
  http.get('/api/user', () => {
    return HttpResponse.json({ id: '1', name: 'John Maverick' })
  }),
  http.post('/api/login', async ({ request }) => {
    const { email } = await request.json()
    return HttpResponse.json({ token: 'mock-jwt-token', email })
  }),
]
```

```typescript
// user.test.ts - override for specific scenarios
import { http, HttpResponse } from 'msw'
import { server } from '../mocks/node'

it('handles authentication error', () => {
  server.use(
    http.get('/api/user', () => {
      return new HttpResponse(null, { status: 401 })
    })
  )
  // Test error handling...
})
```

**When NOT to use this pattern:**
- Single-use test utilities that will never need runtime overrides

Reference: [Structuring Handlers](https://mswjs.io/docs/best-practices/structuring-handlers)
