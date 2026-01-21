---
title: Configure Fake Timers to Preserve queueMicrotask
impact: HIGH
impactDescription: Prevents request body parsing from hanging indefinitely
tags: test, timers, jest, vitest, queueMicrotask, fake-timers
---

## Configure Fake Timers to Preserve queueMicrotask

When using fake timers, configure them to not mock `queueMicrotask`. The global `fetch` uses `queueMicrotask` internally for body parsing, and mocking it causes `request.json()` and similar methods to hang forever.

**Incorrect (default fake timers):**

```typescript
// vitest.config.ts or jest.config.js
beforeEach(() => {
  vi.useFakeTimers()  // Mocks ALL timer functions including queueMicrotask
})

// Test hangs indefinitely
it('parses request body', async () => {
  server.use(
    http.post('/api/user', async ({ request }) => {
      const body = await request.json()  // Never resolves!
      return HttpResponse.json(body)
    })
  )

  await fetch('/api/user', {
    method: 'POST',
    body: JSON.stringify({ name: 'John' }),
  })
})
```

**Correct (exclude queueMicrotask from fake timers):**

```typescript
// Vitest
beforeEach(() => {
  vi.useFakeTimers({
    toFake: [
      'setTimeout',
      'setInterval',
      'clearTimeout',
      'clearInterval',
      'setImmediate',
      'clearImmediate',
      'Date',
    ],
    // queueMicrotask is NOT in the list - remains real
  })
})

// Or more explicitly with shouldAdvanceTime
beforeEach(() => {
  vi.useFakeTimers({ shouldAdvanceTime: true })
})
```

```typescript
// Jest
beforeEach(() => {
  jest.useFakeTimers({
    doNotFake: ['queueMicrotask'],  // Explicitly preserve queueMicrotask
  })
})
```

**Alternative - advance timers after async operations:**

```typescript
it('handles delayed response', async () => {
  vi.useFakeTimers()

  const fetchPromise = fetch('/api/user')

  // Advance timers to allow microtasks to process
  await vi.runAllTimersAsync()

  const response = await fetchPromise
  expect(response.ok).toBe(true)

  vi.useRealTimers()
})
```

**When NOT to use this pattern:**
- If not using fake timers, this configuration is unnecessary

Reference: [MSW Debugging Runbook](https://mswjs.io/docs/runbook/)
