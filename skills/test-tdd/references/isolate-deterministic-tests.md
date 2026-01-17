---
title: Write Deterministic Tests
impact: HIGH
impactDescription: eliminates flaky test failures
tags: isolate, determinism, reliability, flaky-tests
---

## Write Deterministic Tests

Tests must produce the same result every time when code hasn't changed. Non-deterministic tests erode trust and get ignored.

**Incorrect (non-deterministic tests):**

```typescript
test('generates unique order id', () => {
  const order = createOrder()
  // Depends on current time - flaky around midnight
  expect(order.id).toMatch(/^ORD-2024-/)
})

test('token expires in future', () => {
  const token = generateToken()
  // Race condition: might fail if test runs at exact boundary
  expect(token.expiresAt.getTime()).toBeGreaterThan(Date.now())
})

test('shuffles items randomly', () => {
  const items = [1, 2, 3, 4, 5]
  const shuffled = shuffle(items)
  // Non-deterministic: might be same order by chance
  expect(shuffled).not.toEqual(items)
})
```

**Correct (deterministic tests):**

```typescript
test('generates unique order id with date prefix', () => {
  // Inject fixed clock
  const fixedDate = new Date('2024-06-15T10:30:00Z')
  jest.useFakeTimers().setSystemTime(fixedDate)

  const order = createOrder()

  expect(order.id).toMatch(/^ORD-2024-06-15-/)
  jest.useRealTimers()
})

test('token expires 1 hour after creation', () => {
  const fixedNow = new Date('2024-06-15T10:00:00Z')
  jest.useFakeTimers().setSystemTime(fixedNow)

  const token = generateToken()

  const expectedExpiry = new Date('2024-06-15T11:00:00Z')
  expect(token.expiresAt).toEqual(expectedExpiry)
  jest.useRealTimers()
})

test('shuffle changes element positions', () => {
  // Seed random number generator for reproducibility
  const shuffler = createShuffler({ seed: 12345 })
  const items = [1, 2, 3, 4, 5]

  const shuffled = shuffler.shuffle(items)

  // Deterministic with seeded RNG
  expect(shuffled).toEqual([3, 1, 5, 2, 4])
})
```

**Sources of non-determinism to control:**
- Current time/date
- Random number generation
- External API responses
- File system state
- Network latency
- Parallel execution order

Reference: [Flaky Tests - Datadog](https://www.datadoghq.com/knowledge-center/flaky-tests/)
