---
title: Configure Unhandled Request Behavior
impact: CRITICAL
impactDescription: Catches missing handlers immediately; prevents silent test failures
tags: setup, unhandled, error, configuration, onUnhandledRequest
---

## Configure Unhandled Request Behavior

Configure `onUnhandledRequest: 'error'` to fail tests when requests lack handlers. This catches missing mocks immediately instead of allowing silent network calls or undefined behavior.

**Incorrect (default silent behavior):**

```typescript
// mocks/node.ts
import { setupServer } from 'msw/node'
import { handlers } from './handlers'

// Default behavior: warns but doesn't fail
// Unhandled requests may hit real APIs or return undefined
export const server = setupServer(...handlers)
```

```typescript
// Test passes despite missing handler - false positive!
it('submits form', async () => {
  await submitForm({ email: 'test@example.com' })
  // POST /submit has no handler but test doesn't fail
  expect(screen.getByText('Success')).toBeInTheDocument()
})
```

**Correct (strict unhandled request handling):**

```typescript
// vitest.setup.ts
import { server } from './mocks/node'

beforeAll(() => {
  server.listen({
    onUnhandledRequest: 'error', // Fail on any unhandled request
  })
})

afterEach(() => server.resetHandlers())
afterAll(() => server.close())
```

**Custom handling for specific URLs:**

```typescript
beforeAll(() => {
  server.listen({
    onUnhandledRequest(request, print) {
      // Allow certain requests through (e.g., static assets)
      if (request.url.includes('/static/')) {
        return
      }
      // Error on all other unhandled requests
      print.error()
    },
  })
})
```

**When NOT to use this pattern:**
- Development environments may prefer `'warn'` for less disruptive feedback
- Integration tests that intentionally hit real endpoints

Reference: [MSW Best Practices - Avoid Request Assertions](https://mswjs.io/docs/best-practices/avoid-request-assertions/)
