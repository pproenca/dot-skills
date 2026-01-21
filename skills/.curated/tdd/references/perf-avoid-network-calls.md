---
title: Eliminate Network Calls in Unit Tests
impact: MEDIUM
impactDescription: makes tests 10-100× faster
tags: perf, network, mocking, speed
---

## Eliminate Network Calls in Unit Tests

Unit tests should never make real network requests. Network calls are slow, unreliable, and create dependencies on external systems.

**Incorrect (real network calls):**

```typescript
test('fetches user profile', async () => {
  // Real HTTP request - slow, flaky, requires running server
  const response = await fetch('http://localhost:3000/api/users/123')
  const user = await response.json()

  expect(user.name).toBe('Alice')
})

test('sends notification', async () => {
  // Real external API call - costs money, slow, can fail
  const result = await notificationService.send({
    to: 'test@example.com',
    message: 'Hello'
  })

  expect(result.delivered).toBe(true)
})
```

**Correct (mocked network):**

```typescript
test('fetches user profile', async () => {
  // Mock the fetch function
  const mockUser = { id: '123', name: 'Alice', email: 'alice@test.com' }
  global.fetch = jest.fn().mockResolvedValue({
    ok: true,
    json: async () => mockUser
  })

  const user = await userService.getProfile('123')

  expect(user.name).toBe('Alice')
  expect(fetch).toHaveBeenCalledWith(
    expect.stringContaining('/api/users/123')
  )
})

test('sends notification', async () => {
  const mockNotificationApi = {
    send: jest.fn().mockResolvedValue({ delivered: true, messageId: 'm1' })
  }
  const service = new NotificationService(mockNotificationApi)

  const result = await service.send({
    to: 'test@example.com',
    message: 'Hello'
  })

  expect(result.delivered).toBe(true)
  expect(mockNotificationApi.send).toHaveBeenCalledWith({
    to: 'test@example.com',
    message: 'Hello'
  })
})
```

**Mocking strategies:**
- Jest mock functions: `jest.fn()`, `jest.spyOn()`
- Mock service worker (MSW) for HTTP interception
- Dependency injection with fake implementations
- Environment-based mock configuration

Reference: [MSW - Mock Service Worker](https://mswjs.io/)
