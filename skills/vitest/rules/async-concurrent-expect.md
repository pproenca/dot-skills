---
title: Use Test Context Expect in Concurrent Tests
impact: CRITICAL
impactDescription: Prevents snapshot collision and assertion cross-contamination in parallel tests
tags: async, concurrent, test.concurrent, snapshots, parallel
---

## Use Test Context Expect in Concurrent Tests

When using `test.concurrent`, multiple tests run simultaneously. Using the global `expect` can cause snapshot collisions and assertion mix-ups. Extract `expect` from the test context to ensure proper isolation.

**Incorrect (global expect in concurrent tests):**

```typescript
import { describe, test, expect } from 'vitest'

describe('Formatters', () => {
  test.concurrent('formats dates', async () => {
    const result = formatDate(new Date('2024-01-01'))
    // Global expect - snapshots may collide with other concurrent tests
    expect(result).toMatchSnapshot()
  })

  test.concurrent('formats currency', async () => {
    const result = formatCurrency(1234.56)
    expect(result).toMatchSnapshot()
  })
})
```

**Correct (context expect in concurrent tests):**

```typescript
import { describe, test } from 'vitest'

describe('Formatters', () => {
  test.concurrent('formats dates', async ({ expect }) => {
    const result = formatDate(new Date('2024-01-01'))
    // Context expect - properly isolated per test
    expect(result).toMatchSnapshot()
  })

  test.concurrent('formats currency', async ({ expect }) => {
    const result = formatCurrency(1234.56)
    expect(result).toMatchSnapshot()
  })
})
```

**When this matters:**
- When using `test.concurrent` with snapshots
- When concurrent tests share similar assertion patterns
- In large test suites with parallel execution

**Benefits:**
- Each concurrent test has its own expect instance
- Snapshots are correctly tracked per test
- No cross-contamination between parallel tests

Reference: [Vitest Concurrent Tests](https://vitest.dev/api/#test-concurrent)
