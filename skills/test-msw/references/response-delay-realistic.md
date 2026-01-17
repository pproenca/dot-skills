---
title: Add Realistic Response Delays
impact: HIGH
impactDescription: Reveals race conditions; tests loading states; catches timing bugs
tags: response, delay, async, loading, timing
---

## Add Realistic Response Delays

Use `delay()` to simulate network latency in handlers. This reveals race conditions, tests loading states, and ensures your application handles realistic response timing.

**Incorrect (instant responses hide timing issues):**

```typescript
http.get('/api/user', () => {
  // Instant response - loading states never visible
  // Race conditions in component never triggered
  return HttpResponse.json({ name: 'John' })
})
```

```typescript
// Component test passes but has hidden race condition
it('displays user', async () => {
  render(<UserProfile />)
  // Loading state flashes so briefly it's never testable
  expect(await screen.findByText('John')).toBeInTheDocument()
})
```

**Correct (realistic delays):**

```typescript
import { http, HttpResponse, delay } from 'msw'

export const handlers = [
  http.get('/api/user', async () => {
    // Simulate typical API latency
    await delay(150)
    return HttpResponse.json({ name: 'John' })
  }),
]
```

**Testing loading states:**

```typescript
it('shows loading indicator while fetching', async () => {
  server.use(
    http.get('/api/user', async () => {
      await delay(500)  // Longer delay for visibility
      return HttpResponse.json({ name: 'John' })
    })
  )

  render(<UserProfile />)

  // Loading state is visible during delay
  expect(screen.getByText('Loading...')).toBeInTheDocument()

  // Content appears after delay
  expect(await screen.findByText('John')).toBeInTheDocument()
  expect(screen.queryByText('Loading...')).not.toBeInTheDocument()
})
```

**Global delay for all handlers:**

```typescript
import { http, delay } from 'msw'

export const handlers = [
  // Apply delay to all requests
  http.all('*', async () => {
    await delay(100)
    // No return = continue to next matching handler
  }),

  http.get('/api/user', () => {
    return HttpResponse.json({ name: 'John' })
  }),
]
```

**Delay modes:**

```typescript
// Fixed delay
await delay(200)

// Random delay within range (simulates variable network)
await delay('real')  // Random 100-400ms

// Infinite delay (simulates hung request)
await delay('infinite')
```

**When NOT to use this pattern:**
- Unit tests focused on business logic may skip delays for speed
- CI pipelines may use shorter delays to reduce test duration

Reference: [MSW delay() API](https://mswjs.io/docs/api/delay)
