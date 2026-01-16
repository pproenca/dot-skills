---
title: Await Async Assertions
impact: CRITICAL
impactDescription: Prevents false positives where tests pass despite failing assertions
tags: async, promises, assertions, false-positives
---

## Await Async Assertions

Forgetting to await async assertions causes tests to pass before the assertion executes. The test completes successfully while the actual check runs after the test has already passed, hiding real failures.

**Incorrect (missing await):**

```typescript
import { describe, it, expect } from 'vitest'

describe('UserService', () => {
  it('should reject invalid users', () => {
    const service = new UserService()
    // Test passes immediately, assertion runs after test completes
    expect(service.validate({ name: '' })).rejects.toThrow('Name required')
  })
})
```

**Correct (awaited assertion):**

```typescript
import { describe, it, expect } from 'vitest'

describe('UserService', () => {
  it('should reject invalid users', async () => {
    const service = new UserService()
    // Test waits for assertion to complete
    await expect(service.validate({ name: '' })).rejects.toThrow('Name required')
  })
})
```

**Benefits:**
- Tests fail when they should fail
- No silent assertion failures
- Accurate test results

Reference: [Vitest Expect API](https://vitest.dev/api/expect.html)
