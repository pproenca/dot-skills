---
title: One Logical Assertion Per Test
impact: CRITICAL
impactDescription: reduces failure diagnosis time to O(1)
tags: design, single-assertion, focused-tests, clarity
---

## One Logical Assertion Per Test

Each test should verify one logical concept. When a test fails, you should know exactly what's broken without reading the test body.

**Incorrect (multiple unrelated assertions):**

```typescript
test('user service', async () => {
  const user = await userService.create({ name: 'Alice', email: 'alice@test.com' })

  expect(user.id).toBeDefined()
  expect(user.name).toBe('Alice')
  expect(user.email).toBe('alice@test.com')
  expect(user.createdAt).toBeInstanceOf(Date)

  const fetched = await userService.getById(user.id)
  expect(fetched).toEqual(user)

  await userService.delete(user.id)
  expect(await userService.getById(user.id)).toBeNull()
})
// If this fails, which operation broke?
```

**Correct (one concept per test):**

```typescript
describe('UserService', () => {
  describe('create', () => {
    it('generates a unique id', async () => {
      const user = await userService.create({ name: 'Alice', email: 'alice@test.com' })
      expect(user.id).toBeDefined()
    })

    it('stores provided name and email', async () => {
      const user = await userService.create({ name: 'Alice', email: 'alice@test.com' })
      expect(user).toMatchObject({ name: 'Alice', email: 'alice@test.com' })
    })

    it('sets createdAt to current time', async () => {
      const before = new Date()
      const user = await userService.create({ name: 'Alice', email: 'alice@test.com' })
      expect(user.createdAt.getTime()).toBeGreaterThanOrEqual(before.getTime())
    })
  })

  describe('getById', () => {
    it('returns previously created user', async () => {
      const created = await userService.create({ name: 'Alice', email: 'alice@test.com' })
      const fetched = await userService.getById(created.id)
      expect(fetched).toEqual(created)
    })
  })
})
```

**Note:** Multiple `expect` statements are fine when they verify the same logical assertion (e.g., checking multiple properties of a single return value).

Reference: [Unit Testing Best Practices - Microsoft Learn](https://learn.microsoft.com/en-us/dotnet/core/testing/unit-testing-best-practices)
