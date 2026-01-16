---
title: Keep Unit Tests Under 100ms
impact: MEDIUM
impactDescription: enables rapid feedback loops
tags: perf, speed, unit-tests, fast-feedback
---

## Keep Unit Tests Under 100ms

Individual unit tests should complete in milliseconds. Slow tests discourage frequent execution and break the TDD rhythm.

**Incorrect (slow unit test):**

```typescript
test('validates user data', async () => {
  // Real database connection - 50-200ms
  const db = await connectToDatabase()
  await db.seed(testData)

  // Real API call - 100-500ms
  const validationResult = await externalValidationService.validate(userData)

  // File system operations - 10-50ms
  await writeValidationReport(validationResult)

  expect(validationResult.isValid).toBe(true)
})
// Total: 160-750ms per test
// 100 tests = 16-75 seconds
```

**Correct (fast unit test):**

```typescript
test('validates user data format', () => {
  // In-memory, no I/O
  const userData = createUser({ email: 'valid@example.com', age: 25 })

  const result = validateUserData(userData)

  expect(result.isValid).toBe(true)
})
// Total: <5ms

test('returns errors for invalid email', () => {
  const userData = createUser({ email: 'invalid' })

  const result = validateUserData(userData)

  expect(result.errors).toContain('Invalid email format')
})
// Total: <5ms
// 100 tests = <500ms
```

**Techniques for fast tests:**
- Mock external dependencies
- Use in-memory implementations
- Avoid file I/O in unit tests
- Lazy-load expensive resources
- Parallelize independent tests

**Benchmarks:**
- Single unit test: <100ms
- Unit test suite: <10 seconds
- Full test run: <5 minutes

Reference: [The Practical Test Pyramid - Martin Fowler](https://martinfowler.com/articles/practical-test-pyramid.html)
