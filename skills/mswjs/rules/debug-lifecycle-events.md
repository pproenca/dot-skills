---
title: Use Lifecycle Events for Debugging
impact: LOW
impactDescription: Provides visibility into request interception; aids troubleshooting
tags: debug, lifecycle, events, logging, observability
---

## Use Lifecycle Events for Debugging

Subscribe to lifecycle events to observe request interception, matching, and responses. This is invaluable for debugging why handlers aren't matching or responses aren't arriving.

**Incorrect (guessing why requests fail):**

```typescript
// No visibility into what MSW is doing
const server = setupServer(...handlers)
server.listen()

// Tests fail mysteriously - is the handler matching? Is the response correct?
```

**Correct (lifecycle event logging):**

```typescript
import { setupServer } from 'msw/node'
import { handlers } from './handlers'

const server = setupServer(...handlers)

// Log all intercepted requests
server.events.on('request:start', ({ request }) => {
  console.log('MSW intercepted:', request.method, request.url)
})

// Log when a handler matches
server.events.on('request:match', ({ request }) => {
  console.log('MSW matched:', request.method, request.url)
})

// Log completed responses
server.events.on('request:end', ({ request, response }) => {
  console.log(
    'MSW responded:',
    request.method,
    request.url,
    '→',
    response.status
  )
})

// Log unhandled requests
server.events.on('request:unhandled', ({ request }) => {
  console.warn('MSW unhandled:', request.method, request.url)
})
```

**Conditional logging:**

```typescript
// Only log in debug mode
if (process.env.DEBUG_MSW) {
  server.events.on('request:start', ({ request }) => {
    console.log('[MSW]', request.method, request.url)
  })
}
```

**Event types:**
- `request:start` - Request intercepted by MSW
- `request:match` - Handler found for request
- `request:unhandled` - No handler matched
- `request:end` - Response sent (mocked or passthrough)
- `response:mocked` - Mocked response sent
- `response:bypass` - Request passed through to network

**Cleanup:**

```typescript
// Remove event listeners when done
const unsubscribe = server.events.on('request:start', handler)
unsubscribe()  // Remove listener
```

**When NOT to use this pattern:**
- Production builds should not include debug logging
- CI environments may want minimal logging for cleaner output

Reference: [MSW Lifecycle Events](https://mswjs.io/docs/api/life-cycle-events)
