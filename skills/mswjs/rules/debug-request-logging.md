---
title: Log Request Details for Debugging
impact: LOW
impactDescription: Provides detailed request inspection; identifies payload issues
tags: debug, logging, request, inspection, development
---

## Log Request Details for Debugging

Create a debugging middleware handler to log full request details. This helps identify issues with request payloads, headers, and authentication.

**Incorrect (no request visibility):**

```typescript
// Can't see what's being sent to handlers
http.post('/api/user', async ({ request }) => {
  const body = await request.json()
  // body is unexpected - but why?
  return HttpResponse.json({ error: 'Invalid data' }, { status: 400 })
})
```

**Correct (detailed request logging):**

```typescript
import { http, HttpResponse } from 'msw'

// Debug middleware - add as first handler
const debugHandler = http.all('*', async ({ request }) => {
  const url = new URL(request.url)
  const clone = request.clone()

  console.group(`[MSW] ${request.method} ${url.pathname}`)
  console.log('Full URL:', request.url)
  console.log('Headers:', Object.fromEntries(request.headers.entries()))

  // Log body for non-GET requests
  if (request.method !== 'GET' && request.method !== 'HEAD') {
    const contentType = request.headers.get('Content-Type')

    if (contentType?.includes('application/json')) {
      console.log('Body (JSON):', await clone.json())
    } else if (contentType?.includes('multipart/form-data')) {
      const formData = await clone.formData()
      console.log('Body (FormData):', Object.fromEntries(formData.entries()))
    } else {
      console.log('Body (Text):', await clone.text())
    }
  }

  console.groupEnd()

  // Don't return - let next handler process the request
})

export const handlers = [
  debugHandler,  // Must be first
  // ... other handlers
]
```

**Conditional debug mode:**

```typescript
const DEBUG = process.env.DEBUG_MSW === 'true'

export const handlers = [
  ...(DEBUG ? [debugHandler] : []),
  // ... other handlers
]
```

**Response logging:**

```typescript
// Log responses using lifecycle events
server.events.on('request:end', async ({ request, response }) => {
  if (!response) return

  const clone = response.clone()
  const contentType = response.headers.get('Content-Type')

  console.log(`[MSW Response] ${request.method} ${request.url}`)
  console.log('Status:', response.status)

  if (contentType?.includes('application/json')) {
    console.log('Body:', await clone.json())
  }
})
```

**Development browser logging:**

```typescript
// mocks/browser.ts
import { setupWorker } from 'msw/browser'
import { handlers } from './handlers'

export const worker = setupWorker(...handlers)

// Enable detailed logging in development
if (process.env.NODE_ENV === 'development') {
  worker.start({
    onUnhandledRequest: 'warn',
  })
}
```

**When NOT to use this pattern:**
- Remove debug logging before committing/production
- CI should use minimal logging for cleaner output

Reference: [MSW Lifecycle Events](https://mswjs.io/docs/api/life-cycle-events)
