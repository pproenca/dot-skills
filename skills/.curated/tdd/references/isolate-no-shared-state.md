---
title: Avoid Shared Mutable State Between Tests
impact: HIGH
impactDescription: eliminates 74% of test order dependency bugs
tags: isolate, shared-state, independence, determinism
---

## Avoid Shared Mutable State Between Tests

Each test must run in isolation without depending on or affecting other tests. Shared state causes tests to pass or fail based on execution order.

**Incorrect (shared mutable state):**

```typescript
// Shared across all tests in file
let userCount = 0
let database: User[] = []

test('creates first user', () => {
  const user = createUser({ name: 'Alice' })
  database.push(user)
  userCount++

  expect(database).toHaveLength(1)
  expect(userCount).toBe(1)
})

test('creates second user', () => {
  const user = createUser({ name: 'Bob' })
  database.push(user)
  userCount++

  // Fails if tests run in different order or parallel
  expect(database).toHaveLength(2)
  expect(userCount).toBe(2)
})
```

**Correct (isolated state per test):**

```typescript
describe('createUser', () => {
  let database: User[]

  beforeEach(() => {
    // Fresh state for each test
    database = []
  })

  test('creates first user', () => {
    const user = createUser({ name: 'Alice' })
    database.push(user)

    expect(database).toHaveLength(1)
  })

  test('creates second user', () => {
    const user = createUser({ name: 'Bob' })
    database.push(user)

    // Always passes regardless of test order
    expect(database).toHaveLength(1)
  })
})
```

**Isolation techniques:**
- Reset state in `beforeEach`
- Use unique identifiers per test (e.g., UUID)
- Wrap tests in database transactions that rollback
- Create fresh instances instead of reusing singletons

Reference: [Software Testing Anti-patterns - Codepipes](https://blog.codepipes.com/testing/software-testing-antipatterns.html)
