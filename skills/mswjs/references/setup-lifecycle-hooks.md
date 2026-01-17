---
title: Configure Server Lifecycle in Test Setup
impact: CRITICAL
impactDescription: Prevents handler leakage and ensures test isolation; eliminates flaky tests
tags: setup, lifecycle, vitest, jest, beforeAll, afterEach
---

## Configure Server Lifecycle in Test Setup

Server lifecycle hooks must be configured in test setup files to ensure proper initialization, cleanup between tests, and graceful shutdown. Missing hooks cause handler pollution and unpredictable test behavior.

**Incorrect (no lifecycle management):**

```typescript
// handlers.test.ts
import { server } from './mocks/node'

// Server never started, handlers never reset
// Tests may pass/fail randomly depending on execution order
it('fetches user', async () => {
  const response = await fetch('/user')
  // This fails silently - no mocking active
})
```

**Correct (proper lifecycle hooks):**

```typescript
// vitest.setup.ts or setupTests.ts
import { beforeAll, afterEach, afterAll } from 'vitest'
import { server } from './mocks/node'

// Start server before all tests
beforeAll(() => server.listen())

// Reset handlers after each test to ensure isolation
afterEach(() => server.resetHandlers())

// Clean shutdown after all tests complete
afterAll(() => server.close())
```

**Jest equivalent:**

```typescript
// setupTests.ts
import { server } from './mocks/node'

beforeAll(() => server.listen())
afterEach(() => server.resetHandlers())
afterAll(() => server.close())
```

**When NOT to use this pattern:**
- Browser-based tests use `worker.start()` and `worker.stop()` instead

Reference: [MSW Quick Start - Test Setup](https://mswjs.io/docs/quick-start)
