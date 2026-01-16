---
title: Share Handlers Across Environments
impact: CRITICAL
impactDescription: Single source of truth; eliminates mock drift between dev/test
tags: handler, reuse, environment, browser, node, integration
---

## Share Handlers Across Environments

Define handlers once and reuse them across browser (development) and Node.js (testing) environments. This ensures mock behavior is consistent and prevents drift between development and test mocks.

**Incorrect (duplicate handlers per environment):**

```typescript
// mocks/browser-handlers.ts - browser development
export const browserHandlers = [
  http.get('/api/user', () => HttpResponse.json({ name: 'Dev User' })),
]

// mocks/test-handlers.ts - tests (different implementation!)
export const testHandlers = [
  http.get('/api/user', () => HttpResponse.json({ name: 'Test User' })),
]
// Mock behavior differs between environments - bugs hide until production
```

**Correct (shared handlers, environment-specific setup):**

```typescript
// mocks/handlers.ts - single source of truth
import { http, HttpResponse } from 'msw'

export const handlers = [
  http.get('/api/user', () => {
    return HttpResponse.json({ id: '1', name: 'John Maverick' })
  }),
  http.get('/api/posts', () => {
    return HttpResponse.json([
      { id: '1', title: 'First Post' },
      { id: '2', title: 'Second Post' },
    ])
  }),
]
```

```typescript
// mocks/browser.ts - browser setup
import { setupWorker } from 'msw/browser'
import { handlers } from './handlers'

export const worker = setupWorker(...handlers)
```

```typescript
// mocks/node.ts - Node.js setup
import { setupServer } from 'msw/node'
import { handlers } from './handlers'

export const server = setupServer(...handlers)
```

```typescript
// src/index.tsx - conditional browser activation
async function enableMocking() {
  if (process.env.NODE_ENV !== 'development') {
    return
  }
  const { worker } = await import('./mocks/browser')
  return worker.start()
}

enableMocking().then(() => {
  ReactDOM.createRoot(document.getElementById('root')!).render(<App />)
})
```

**When NOT to use this pattern:**
- Environment-specific handlers (e.g., browser-only features) can be added via separate arrays

Reference: [MSW Comparison - Reusability](https://mswjs.io/docs/comparison)
