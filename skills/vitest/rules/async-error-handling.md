---
title: Test Async Error Handling Properly
impact: CRITICAL
impactDescription: Prevents tests from passing when async operations fail silently
tags: async, errors, rejects, try-catch, error-handling
---

## Test Async Error Handling Properly

Testing that async functions throw errors requires proper assertion patterns. Using try-catch manually is error-prone - if the function doesn't throw, the test passes incorrectly. Use `expect().rejects` for clean, reliable error testing.

**Incorrect (manual try-catch):**

```typescript
import { describe, it, expect } from 'vitest'

describe('API', () => {
  it('should throw on invalid input', async () => {
    try {
      await api.createUser({ email: 'invalid' })
      // If we forget this line, test passes when it shouldn't
      // expect.fail('Should have thrown')
    } catch (error) {
      expect(error.message).toContain('Invalid email')
    }
  })
})
```

**Correct (expect.rejects):**

```typescript
import { describe, it, expect } from 'vitest'

describe('API', () => {
  it('should throw on invalid input', async () => {
    // Automatically fails if promise resolves instead of rejects
    await expect(api.createUser({ email: 'invalid' }))
      .rejects.toThrow('Invalid email')
  })
})
```

**Testing specific error types:**

```typescript
describe('API', () => {
  it('should throw ValidationError on invalid input', async () => {
    await expect(api.createUser({ email: 'invalid' }))
      .rejects.toThrow(ValidationError)
  })

  it('should include error details', async () => {
    await expect(api.createUser({ email: 'invalid' }))
      .rejects.toMatchObject({
        code: 'VALIDATION_ERROR',
        field: 'email',
      })
  })
})
```

**When NOT to use this pattern:**
- When testing that a function doesn't throw (use regular await)
- When you need to inspect multiple properties of the caught error

**Benefits:**
- Test fails if promise resolves unexpectedly
- Clean, declarative syntax
- Works with error instances, messages, and matchers

Reference: [Vitest Expect Rejects](https://vitest.dev/api/expect.html#rejects)
