---
title: Fix Flaky Tests Immediately
impact: MEDIUM
impactDescription: preserves trust in test suite
tags: perf, flaky, reliability, maintenance
---

## Fix Flaky Tests Immediately

A flaky test is one that sometimes passes and sometimes fails without code changes. Fix or quarantine flaky tests immediately - they erode trust in the entire suite.

**Incorrect (ignoring flaky tests):**

```typescript
test('processes concurrent requests', async () => {
  // Race condition - passes 90% of the time
  const results = await Promise.all([
    service.process(request1),
    service.process(request2)
  ])

  // Sometimes fails due to timing
  expect(results[0].completedBefore(results[1])).toBe(true)
})

// Team learns to just re-run failed builds
// Eventually ignores all test failures
// Real bugs slip through
```

**Correct (fix the root cause):**

```typescript
test('processes requests in order received', async () => {
  // Control the timing explicitly
  const processOrder: string[] = []

  const mockProcessor = {
    process: jest.fn().mockImplementation(async (req) => {
      processOrder.push(req.id)
      return { id: req.id, timestamp: Date.now() }
    })
  }

  const service = new RequestService(mockProcessor)

  await service.processInOrder([
    { id: 'req-1' },
    { id: 'req-2' }
  ])

  // Assert on the controlled behavior
  expect(processOrder).toEqual(['req-1', 'req-2'])
})

// Alternative: fix the async timing issue
test('handles concurrent requests', async () => {
  const startTime = Date.now()

  const results = await Promise.all([
    service.process(request1),
    service.process(request2)
  ])

  // Assert on stable properties, not timing
  expect(results).toHaveLength(2)
  expect(results.every(r => r.status === 'completed')).toBe(true)
})
```

**Flaky test triage:**
1. Identify: Track flaky test frequency
2. Quarantine: Move to separate suite if can't fix immediately
3. Fix: Address root cause (timing, shared state, external deps)
4. Prevent: Add monitoring for new flaky tests

**Common causes:**
- Race conditions and timing dependencies
- Shared mutable state
- External service dependencies
- Non-deterministic data (time, random)

Reference: [Flaky Tests Mitigation - Semaphore](https://semaphore.io/blog/flaky-tests-mitigation)
