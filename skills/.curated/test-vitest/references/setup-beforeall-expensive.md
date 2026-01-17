---
title: Use beforeAll for Expensive One-Time Setup
impact: HIGH
impactDescription: Reduces test suite time by 50-90% for tests with expensive setup
tags: setup, beforeAll, performance, database, fixtures
---

## Use beforeAll for Expensive One-Time Setup

Operations like database connections, file system setup, or API client initialization should run once per suite, not before every test. Using `beforeEach` for expensive operations multiplies execution time unnecessarily.

**Incorrect (expensive setup in beforeEach):**

```typescript
import { describe, it, expect, beforeEach, afterEach } from 'vitest'

describe('DatabaseRepository', () => {
  let db: Database

  beforeEach(async () => {
    // 500ms connection time × number of tests
    db = await Database.connect(connectionString)
    await db.migrate()
  })

  afterEach(async () => {
    await db.disconnect()
  })

  it('should create record', async () => { /* ... */ })
  it('should read record', async () => { /* ... */ })
  it('should update record', async () => { /* ... */ })
  // 10 tests = 5000ms just for setup
})
```

**Correct (one-time setup with beforeAll):**

```typescript
import { describe, it, expect, beforeAll, afterAll, beforeEach } from 'vitest'

describe('DatabaseRepository', () => {
  let db: Database

  beforeAll(async () => {
    // 500ms once for entire suite
    db = await Database.connect(connectionString)
    await db.migrate()
  })

  afterAll(async () => {
    await db.disconnect()
  })

  beforeEach(async () => {
    // Only reset data between tests, not connection
    await db.truncate('users')
  })

  it('should create record', async () => { /* ... */ })
  it('should read record', async () => { /* ... */ })
  it('should update record', async () => { /* ... */ })
  // 10 tests = 500ms setup total
})
```

**When to use each:**

| Hook | Use For |
|------|---------|
| `beforeAll` | Database connections, server startup, expensive fixtures |
| `beforeEach` | Resetting state, seeding test data, creating fresh instances |
| `afterEach` | Clearing state, restoring mocks |
| `afterAll` | Closing connections, cleanup after all tests |

**Benefits:**
- Dramatic reduction in test suite time
- Faster feedback loops
- More efficient CI/CD runs

Reference: [Vitest Setup and Teardown](https://vitest.dev/api/#setup-and-teardown)
