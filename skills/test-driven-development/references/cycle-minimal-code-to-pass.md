---
title: Write Only Enough Code to Pass the Test
impact: CRITICAL
impactDescription: prevents over-engineering and YAGNI violations
tags: cycle, green-phase, minimal-implementation, yagni
---

## Write Only Enough Code to Pass the Test

In the GREEN phase, write the absolute minimum code needed to make the failing test pass. Resist the urge to add features, optimizations, or "obvious" improvements not yet required by a test.

**Incorrect (over-engineering in GREEN phase):**

```typescript
test('returns user by id', async () => {
  const user = await userService.getById('user-123')
  expect(user.id).toBe('user-123')
})

// Implementation does more than needed
class UserService {
  private cache = new Map<string, User>()
  private logger = new Logger()

  async getById(id: string): Promise<User> {
    // Caching not required by any test yet
    if (this.cache.has(id)) {
      this.logger.info('Cache hit', { id })
      return this.cache.get(id)!
    }

    const user = await this.repository.findById(id)
    this.cache.set(id, user)
    this.logger.info('Cache miss', { id })
    return user
  }
}
```

**Correct (minimal implementation):**

```typescript
test('returns user by id', async () => {
  const user = await userService.getById('user-123')
  expect(user.id).toBe('user-123')
})

// Implementation does exactly what's needed
class UserService {
  async getById(id: string): Promise<User> {
    return this.repository.findById(id)
  }
}
// Add caching only when a test requires it
```

**When to expand:**
- Only when a new test requires additional behavior
- During the REFACTOR phase for structural improvements
- Never add untested features "while you're in there"

Reference: [The Cycles of TDD - Clean Coder Blog](http://blog.cleancoder.com/uncle-bob/2014/12/17/TheCyclesOfTDD.html)
