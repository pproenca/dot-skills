---
title: Use bypass() for Passthrough Requests
impact: MEDIUM
impactDescription: Enables mixing real and mocked APIs; supports hybrid testing
tags: advanced, bypass, passthrough, real-api, proxy
---

## Use bypass() for Passthrough Requests

Use `bypass()` to mark requests that should skip MSW interception and hit the real server. This enables hybrid scenarios where some APIs are mocked and others are real.

**Incorrect (request creates infinite loop):**

```typescript
// Making a fetch inside a handler without bypass creates infinite recursion
http.get('/api/user', async () => {
  // This request is intercepted by this same handler!
  const realResponse = await fetch('/api/user')  // Infinite loop
  return realResponse
})
```

**Correct (bypass MSW interception):**

```typescript
import { http, HttpResponse, bypass } from 'msw'

export const handlers = [
  // Proxy to real API and modify response
  http.get('/api/user', async ({ request }) => {
    // bypass() marks the request to skip MSW
    const realResponse = await fetch(bypass(request))
    const realData = await realResponse.json()

    // Augment real data with mock data
    return HttpResponse.json({
      ...realData,
      mockField: 'added by MSW',
    })
  }),

  // Conditional passthrough
  http.get('/api/data', async ({ request }) => {
    const url = new URL(request.url)

    // Only mock in test environment
    if (url.searchParams.get('mock') !== 'true') {
      return fetch(bypass(request))
    }

    return HttpResponse.json({ mocked: true })
  }),
]
```

**Using passthrough() for unconditional passthrough:**

```typescript
import { http, passthrough } from 'msw'

export const handlers = [
  // Always pass through to real API
  http.get('/api/analytics/*', () => {
    return passthrough()
  }),

  // Pass through external APIs
  http.all('https://external-service.com/*', () => {
    return passthrough()
  }),
]
```

**Difference between bypass and passthrough:**
- `bypass(request)`: Use inside a handler to make a real request
- `passthrough()`: Return from handler to let the original request through

**When NOT to use this pattern:**
- Fully mocked environments should avoid real API calls

Reference: [MSW bypass API](https://mswjs.io/docs/api/bypass)
