---
title: Return Promises from Test Functions
impact: CRITICAL
impactDescription: Prevents tests from completing before async operations finish
tags: async, promises, test-completion, race-conditions
---

## Return Promises from Test Functions

When a test function returns a promise, Vitest waits for it to resolve before marking the test complete. Forgetting to return the promise causes the test to finish prematurely, potentially hiding failures.

**Incorrect (promise not returned):**

```typescript
import { describe, it, expect } from 'vitest'

describe('API', () => {
  it('should fetch user data', () => {
    // Promise is created but not returned - test completes immediately
    fetchUser(1).then(user => {
      expect(user.name).toBe('Alice')
    })
  })
})
```

**Correct (promise returned):**

```typescript
import { describe, it, expect } from 'vitest'

describe('API', () => {
  it('should fetch user data', () => {
    // Returning the promise ensures Vitest waits for completion
    return fetchUser(1).then(user => {
      expect(user.name).toBe('Alice')
    })
  })
})
```

**Alternative (async/await - preferred):**

```typescript
import { describe, it, expect } from 'vitest'

describe('API', () => {
  it('should fetch user data', async () => {
    const user = await fetchUser(1)
    expect(user.name).toBe('Alice')
  })
})
```

**Benefits:**
- Test runner waits for all assertions
- Failed promises cause test failures
- Clearer async flow with async/await

Reference: [Vitest Test API](https://vitest.dev/api/)
