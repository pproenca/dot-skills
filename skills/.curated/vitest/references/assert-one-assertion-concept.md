---
title: Test One Concept Per Test
impact: LOW-MEDIUM
impactDescription: Improves failure diagnosis and test maintainability
tags: assert, organization, single-responsibility, test-design
---

## Test One Concept Per Test

Tests that verify multiple unrelated behaviors are hard to debug when they fail. You can't tell which behavior broke. Split tests so each focuses on one concept.

**Incorrect (multiple concepts):**

```typescript
import { describe, it, expect } from 'vitest'

describe('User', () => {
  it('should work correctly', () => {
    const user = new User('Alice', 'alice@test.com')

    // Testing creation
    expect(user.name).toBe('Alice')
    expect(user.email).toBe('alice@test.com')

    // Testing validation
    expect(user.isValid()).toBe(true)

    // Testing formatting
    expect(user.toString()).toBe('Alice <alice@test.com>')

    // Testing update
    user.updateEmail('new@test.com')
    expect(user.email).toBe('new@test.com')

    // If this test fails, which behavior is broken?
  })
})
```

**Correct (one concept per test):**

```typescript
import { describe, it, expect } from 'vitest'

describe('User', () => {
  describe('creation', () => {
    it('should set name and email from constructor', () => {
      const user = new User('Alice', 'alice@test.com')
      expect(user.name).toBe('Alice')
      expect(user.email).toBe('alice@test.com')
    })
  })

  describe('validation', () => {
    it('should be valid with proper name and email', () => {
      const user = new User('Alice', 'alice@test.com')
      expect(user.isValid()).toBe(true)
    })

    it('should be invalid with empty name', () => {
      const user = new User('', 'alice@test.com')
      expect(user.isValid()).toBe(false)
    })
  })

  describe('formatting', () => {
    it('should format as "name <email>"', () => {
      const user = new User('Alice', 'alice@test.com')
      expect(user.toString()).toBe('Alice <alice@test.com>')
    })
  })

  describe('updateEmail', () => {
    it('should update the email address', () => {
      const user = new User('Alice', 'alice@test.com')
      user.updateEmail('new@test.com')
      expect(user.email).toBe('new@test.com')
    })
  })
})
```

**Signs of testing too much:**
- Test name uses "and" (e.g., "should create and validate")
- More than 5-7 assertions
- Test requires complex setup for unrelated behaviors
- Test name is vague ("should work", "handles everything")

**Benefits:**
- Failing tests clearly indicate what broke
- Easy to add new test cases
- Tests serve as documentation

Reference: [Vitest Test Organization](https://vitest.dev/api/)
