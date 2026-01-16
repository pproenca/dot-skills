---
title: Use server.boundary() for Concurrent Tests
impact: HIGH
impactDescription: Enables parallel test execution; prevents cross-test handler pollution
tags: test, concurrent, boundary, isolation, parallel
---

## Use server.boundary() for Concurrent Tests

Wrap concurrent tests in `server.boundary()` to isolate handler overrides. Without boundaries, concurrent tests share handlers, causing race conditions and unpredictable failures.

**Incorrect (concurrent tests without boundaries):**

```typescript
// Tests run in parallel - handlers leak between them
it.concurrent('fetches user', async () => {
  // Uses initial handlers
  const response = await fetch('https://api.example.com/user')
  expect(response.ok).toBe(true)
})

it.concurrent('handles error', async () => {
  server.use(
    http.get('https://api.example.com/user', () => {
      return new HttpResponse(null, { status: 500 })
    })
  )
  // This override might affect the other concurrent test!
  const response = await fetch('https://api.example.com/user')
  expect(response.status).toBe(500)
})
```

**Correct (boundary-isolated concurrent tests):**

```typescript
import { http, HttpResponse } from 'msw'
import { setupServer } from 'msw/node'

const server = setupServer(
  http.get('https://api.example.com/user', () => {
    return HttpResponse.json({ name: 'John' })
  })
)

beforeAll(() => server.listen())
afterAll(() => server.close())

it.concurrent(
  'fetches user',
  server.boundary(async () => {
    const response = await fetch('https://api.example.com/user')
    const user = await response.json()
    expect(user).toEqual({ name: 'John' })
  })
)

it.concurrent(
  'handles server error',
  server.boundary(async () => {
    // Override is scoped to this boundary only
    server.use(
      http.get('https://api.example.com/user', () => {
        return new HttpResponse(null, { status: 500 })
      })
    )
    const response = await fetch('https://api.example.com/user')
    expect(response.status).toBe(500)
  })
)

it.concurrent(
  'handles network error',
  server.boundary(async () => {
    server.use(
      http.get('https://api.example.com/user', () => {
        return HttpResponse.error()
      })
    )
    await expect(fetch('https://api.example.com/user')).rejects.toThrow()
  })
)
```

**When NOT to use this pattern:**
- Sequential tests (non-concurrent) can use standard `afterEach` reset pattern

Reference: [server.boundary() API](https://mswjs.io/docs/api/setup-server/boundary)
