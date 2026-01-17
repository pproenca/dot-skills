---
title: Avoid Shared Mutable State Between Tests
impact: CRITICAL
impactDescription: Eliminates order-dependent test failures and enables reliable parallel execution
tags: setup, isolation, shared-state, test-independence, flaky-tests
---

## Avoid Shared Mutable State Between Tests

Sharing mutable state between tests creates hidden dependencies. Tests pass when run alone but fail in the suite, or fail only when run in a specific order. Each test must create its own state.

**Incorrect (shared mutable state):**

```typescript
import { describe, it, expect, beforeAll } from 'vitest'

// Shared state - modified by tests
const testUsers: User[] = []

describe('UserRepository', () => {
  beforeAll(() => {
    testUsers.push({ id: 1, name: 'Alice' })
  })

  it('should find user by id', () => {
    const user = repository.find(testUsers, 1)
    expect(user.name).toBe('Alice')
  })

  it('should add new user', () => {
    testUsers.push({ id: 2, name: 'Bob' })
    expect(testUsers).toHaveLength(2)
  })

  it('should list all users', () => {
    // FLAKY - depends on previous test running first
    // May have 1 or 2 users depending on test order
    expect(repository.list(testUsers)).toHaveLength(2)
  })
})
```

**Correct (isolated state per test):**

```typescript
import { describe, it, expect, beforeEach } from 'vitest'

describe('UserRepository', () => {
  let testUsers: User[]

  beforeEach(() => {
    // Fresh state for each test
    testUsers = [{ id: 1, name: 'Alice' }]
  })

  it('should find user by id', () => {
    const user = repository.find(testUsers, 1)
    expect(user.name).toBe('Alice')
  })

  it('should add new user', () => {
    testUsers.push({ id: 2, name: 'Bob' })
    expect(testUsers).toHaveLength(2)
  })

  it('should list all users', () => {
    // Always 1 user - independent of other tests
    expect(repository.list(testUsers)).toHaveLength(1)
  })
})
```

**Factory pattern for complex state:**

```typescript
function createTestUser(overrides?: Partial<User>): User {
  return {
    id: Math.random(),
    name: 'Test User',
    email: 'test@example.com',
    ...overrides,
  }
}

describe('UserService', () => {
  it('should validate user email', () => {
    const user = createTestUser({ email: 'invalid' })
    expect(service.validate(user)).toBe(false)
  })
})
```

**Benefits:**
- Tests can run in any order
- Tests can run in parallel safely
- Failures are isolated and easy to debug

Reference: [Vitest Test Isolation](https://vitest.dev/guide/improving-performance#test-isolation)
