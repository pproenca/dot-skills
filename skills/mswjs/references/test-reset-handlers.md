---
title: Reset Handlers After Each Test
impact: HIGH
impactDescription: Prevents handler pollution; eliminates test order dependencies
tags: test, reset, isolation, afterEach, resetHandlers
---

## Reset Handlers After Each Test

Call `server.resetHandlers()` in `afterEach` to remove runtime handlers added during tests. Without reset, handlers from one test can affect subsequent tests, causing mysterious failures that depend on test execution order.

**Incorrect (no handler reset):**

```typescript
// test-a.spec.ts
it('handles server error', () => {
  server.use(
    http.get('/api/user', () => new HttpResponse(null, { status: 500 }))
  )
  // Test passes...
})

// test-b.spec.ts - runs after test-a
it('displays user name', () => {
  // FAILS! Still receiving 500 error from test-a's handler
  render(<UserProfile />)
  expect(screen.getByText('John')).toBeInTheDocument()
})
```

**Correct (reset in afterEach):**

```typescript
// vitest.setup.ts
import { server } from './mocks/node'

beforeAll(() => server.listen())
afterEach(() => server.resetHandlers())  // Clean slate for each test
afterAll(() => server.close())
```

```typescript
// user.test.ts
it('handles server error', () => {
  server.use(
    http.get('/api/user', () => new HttpResponse(null, { status: 500 }))
  )
  render(<UserProfile />)
  expect(screen.getByRole('alert')).toHaveTextContent('Error')
})
// Handler is removed after this test completes

it('displays user name', () => {
  // Uses baseline happy-path handler
  render(<UserProfile />)
  expect(screen.getByText('John')).toBeInTheDocument()
})
```

**When NOT to use this pattern:**
- `server.boundary()` provides automatic isolation for concurrent tests

Reference: [Network Behavior Overrides](https://mswjs.io/docs/best-practices/network-behavior-overrides)
