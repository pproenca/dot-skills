---
title: Verify Request Interception is Working
impact: LOW
impactDescription: Confirms MSW is active; identifies setup failures early
tags: debug, verification, setup, troubleshooting, runbook
---

## Verify Request Interception is Working

Add a verification step to confirm MSW is intercepting requests. This catches configuration issues before they cause mysterious test failures.

**Incorrect (assuming MSW is working):**

```typescript
// No verification - tests fail with confusing errors
beforeAll(() => server.listen())

it('fetches user', async () => {
  // If MSW isn't working, this hits real API or fails silently
  const response = await fetch('/api/user')
})
```

**Correct (verify interception):**

```typescript
import { setupServer } from 'msw/node'
import { handlers } from './handlers'

const server = setupServer(...handlers)

beforeAll(() => {
  server.listen()

  // Verify MSW is intercepting
  server.events.on('request:start', ({ request }) => {
    console.log('✓ MSW intercepted:', request.method, request.url)
  })
})

// Or create a verification test
describe('MSW Setup', () => {
  it('intercepts requests', async () => {
    let intercepted = false

    server.events.on('request:start', () => {
      intercepted = true
    })

    await fetch('/api/health')

    expect(intercepted).toBe(true)
  })
})
```

**Debugging checklist when handlers don't match:**

```typescript
// Step 1: Verify interception is happening
server.events.on('request:start', ({ request }) => {
  console.log('Intercepted URL:', request.url)  // Check if URL is absolute
  console.log('Intercepted method:', request.method)
})

// Step 2: Add console.log inside handler
http.get('/api/user', () => {
  console.log('Handler matched!')  // If this doesn't log, handler isn't matching
  return HttpResponse.json({ name: 'John' })
})

// Step 3: Check handler URL vs request URL
// Common issues:
// - Handler: '/api/user' but request goes to 'http://localhost:3000/api/user'
// - Environment variable in URL is undefined
// - Typo in URL path
```

**Browser verification:**

```typescript
// In browser console
const { worker } = await import('./mocks/browser')
await worker.start()

// Check if worker script is accessible
fetch('/mockServiceWorker.js')
  .then((r) => r.ok ? 'Worker script found' : 'Worker script missing')
  .then(console.log)
```

**When NOT to use this pattern:**
- Stable test suites don't need verification in every run

Reference: [MSW Debugging Runbook](https://mswjs.io/docs/runbook/)
