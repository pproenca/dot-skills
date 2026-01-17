---
title: Use MSW for Network Request Mocking
impact: HIGH
impactDescription: Provides realistic request/response mocking at the network level
tags: mock, msw, network, api-mocking, http, fetch
---

## Use MSW for Network Request Mocking

Mocking fetch or axios directly means you're not testing the actual HTTP layer. MSW (Mock Service Worker) intercepts real network requests, providing realistic mocking that catches integration issues.

**Incorrect (mocking fetch directly):**

```typescript
import { describe, it, expect, vi, beforeEach } from 'vitest'

describe('UserAPI', () => {
  beforeEach(() => {
    // Mocks the fetch function, not the network behavior
    global.fetch = vi.fn().mockResolvedValue({
      ok: true,
      json: () => Promise.resolve({ id: 1, name: 'Alice' }),
    })
  })

  it('should fetch user', async () => {
    const user = await api.getUser(1)
    expect(user.name).toBe('Alice')
    // Doesn't test: request headers, URL construction, error status codes
  })
})
```

**Correct (MSW for network mocking):**

```typescript
import { describe, it, expect, beforeAll, afterAll, afterEach } from 'vitest'
import { setupServer } from 'msw/node'
import { http, HttpResponse } from 'msw'

const server = setupServer(
  http.get('/api/users/:id', ({ params }) => {
    return HttpResponse.json({ id: params.id, name: 'Alice' })
  }),

  http.post('/api/users', async ({ request }) => {
    const body = await request.json()
    return HttpResponse.json({ id: 1, ...body }, { status: 201 })
  }),
)

beforeAll(() => server.listen())
afterEach(() => server.resetHandlers())
afterAll(() => server.close())

describe('UserAPI', () => {
  it('should fetch user', async () => {
    const user = await api.getUser(1)
    expect(user.name).toBe('Alice')
  })

  it('should handle 404', async () => {
    server.use(
      http.get('/api/users/:id', () => {
        return new HttpResponse(null, { status: 404 })
      }),
    )

    await expect(api.getUser(999)).rejects.toThrow('User not found')
  })

  it('should create user', async () => {
    const user = await api.createUser({ name: 'Bob' })
    expect(user.id).toBe(1)
  })
})
```

**Setup file for global MSW:**

```typescript
// vitest.setup.ts
import { beforeAll, afterAll, afterEach } from 'vitest'
import { server } from './mocks/server'

beforeAll(() => server.listen({ onUnhandledRequest: 'error' }))
afterEach(() => server.resetHandlers())
afterAll(() => server.close())
```

**Benefits:**
- Tests real HTTP behavior (headers, status codes, body parsing)
- Catches URL construction bugs
- Same mock handlers work in tests and development

Reference: [MSW Documentation](https://mswjs.io/docs/)
