---
title: Configure MSW for Vitest Browser Mode
impact: MEDIUM
impactDescription: Enables browser-environment testing with proper worker setup
tags: advanced, vitest, browser, worker, testing
---

## Configure MSW for Vitest Browser Mode

Extend Vitest's test context to include the MSW worker when testing in browser mode. This ensures proper worker lifecycle management per test.

**Incorrect (global worker without test context):**

```typescript
// Worker state leaks between tests
import { worker } from './mocks/browser'

beforeAll(() => worker.start())
afterAll(() => worker.stop())

// Tests can't override handlers safely
```

**Correct (extended test context):**

```typescript
// test-extend.ts
import { test as testBase } from 'vitest'
import { worker } from './mocks/browser'

export const test = testBase.extend({
  worker: [
    async ({}, use) => {
      // Start worker before test
      await worker.start({
        onUnhandledRequest: 'error',
      })

      // Provide worker to test
      await use(worker)

      // Reset handlers after test
      worker.resetHandlers()
    },
    {
      auto: true,  // Automatically available to all tests
    },
  ],
})

export { expect } from 'vitest'
```

```typescript
// user.test.ts
import { http, HttpResponse } from 'msw'
import { test, expect } from './test-extend'
import { Dashboard } from './components/Dashboard'

test('displays user data', async ({ worker }) => {
  // Worker is automatically started
  render(<Dashboard />)
  expect(await screen.findByText('John')).toBeInTheDocument()
})

test('handles error state', async ({ worker }) => {
  // Override handlers for this test
  worker.use(
    http.get('/api/user', () => {
      return new HttpResponse(null, { status: 500 })
    })
  )

  render(<Dashboard />)
  expect(await screen.findByText('Error loading')).toBeInTheDocument()
})
```

**Vitest config for browser mode:**

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    browser: {
      enabled: true,
      name: 'chromium',
      provider: 'playwright',
    },
    setupFiles: ['./vitest.setup.ts'],
  },
})
```

**When NOT to use this pattern:**
- Node.js tests should use `setupServer` instead

Reference: [MSW Vitest Browser Mode](https://mswjs.io/docs/recipes/vitest-browser-mode)
