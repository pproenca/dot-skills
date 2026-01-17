---
title: Use One-Time Handlers for Sequential Scenarios
impact: HIGH
impactDescription: Models realistic multi-step flows; tests retry logic correctly
tags: response, once, one-time, sequential, retry
---

## Use One-Time Handlers for Sequential Scenarios

Use the `{ once: true }` option for handlers that should only respond once, then fall back to the next matching handler. This is essential for testing retry logic, sequential API calls, or state changes between requests.

**Incorrect (permanent override prevents testing retries):**

```typescript
it('retries after failure', async () => {
  server.use(
    http.get('/api/user', () => {
      return new HttpResponse(null, { status: 500 })
    })
  )

  render(<UserProfile />)

  // Component retries, but always gets 500 - can't test success after retry
  await userEvent.click(screen.getByRole('button', { name: 'Retry' }))
  // Still failing...
})
```

**Correct (one-time handler for first request):**

```typescript
import { http, HttpResponse } from 'msw'

it('retries after failure and succeeds', async () => {
  server.use(
    http.get(
      '/api/user',
      () => {
        return new HttpResponse(null, { status: 500 })
      },
      { once: true }  // Only affects first request
    )
  )

  render(<UserProfile />)

  // First request fails
  expect(await screen.findByText('Error loading user')).toBeInTheDocument()

  // Retry succeeds (uses baseline happy-path handler)
  await userEvent.click(screen.getByRole('button', { name: 'Retry' }))
  expect(await screen.findByText('John')).toBeInTheDocument()
})
```

**Sequential state changes:**

```typescript
it('shows optimistic update then server response', async () => {
  let callCount = 0

  server.use(
    http.post('/api/like', () => {
      callCount++
      if (callCount === 1) {
        // First call - slow response simulates network
        return HttpResponse.json({ likes: 11 })
      }
      // Subsequent calls
      return HttpResponse.json({ likes: 12 })
    })
  )

  // Test optimistic update behavior
})
```

**Multiple sequential states:**

```typescript
server.use(
  // First request: pending
  http.get('/api/order/:id', () => {
    return HttpResponse.json({ status: 'pending' })
  }, { once: true }),

  // Second request: processing
  http.get('/api/order/:id', () => {
    return HttpResponse.json({ status: 'processing' })
  }, { once: true }),

  // Third+ requests: completed
  http.get('/api/order/:id', () => {
    return HttpResponse.json({ status: 'completed' })
  })
)
```

**When NOT to use this pattern:**
- Single-state tests that don't involve retries or polling

Reference: [Network Behavior Overrides](https://mswjs.io/docs/best-practices/network-behavior-overrides)
