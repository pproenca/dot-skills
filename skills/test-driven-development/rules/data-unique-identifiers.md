---
title: Use Unique Identifiers Per Test
impact: HIGH
impactDescription: prevents test pollution
tags: data, identifiers, isolation, uniqueness
---

## Use Unique Identifiers Per Test

Generate unique IDs for test entities to prevent conflicts between tests running in parallel or sharing a database.

**Incorrect (hard-coded IDs):**

```typescript
test('creates user', async () => {
  await userService.create({ id: 'user-1', email: 'test@example.com' })
  const user = await userService.getById('user-1')
  expect(user.email).toBe('test@example.com')
})

test('updates user', async () => {
  // Uses same ID - fails if tests run in parallel or wrong order
  await userService.create({ id: 'user-1', email: 'test@example.com' })
  await userService.update('user-1', { email: 'new@example.com' })
  const user = await userService.getById('user-1')
  expect(user.email).toBe('new@example.com')
})

test('deletes user', async () => {
  // May delete user from other test
  await userService.delete('user-1')
  expect(await userService.getById('user-1')).toBeNull()
})
```

**Correct (unique IDs):**

```typescript
function uniqueId(prefix: string = ''): string {
  return `${prefix}${Date.now()}-${Math.random().toString(36).slice(2)}`
}

test('creates user', async () => {
  const userId = uniqueId('user-')
  const email = `${uniqueId()}@example.com`

  await userService.create({ id: userId, email })
  const user = await userService.getById(userId)

  expect(user.email).toBe(email)
})

test('updates user', async () => {
  const userId = uniqueId('user-')
  await userService.create({ id: userId, email: 'original@example.com' })

  await userService.update(userId, { email: 'updated@example.com' })

  const user = await userService.getById(userId)
  expect(user.email).toBe('updated@example.com')
})

// Or use factory that generates unique IDs automatically
test('deletes user', async () => {
  const user = await createAndSaveUser()

  await userService.delete(user.id)

  expect(await userService.getById(user.id)).toBeNull()
})
```

**Benefits:**
- Tests can run in any order
- Tests can run in parallel
- No cleanup needed between tests
- Failures are isolated to single test

Reference: [How to deal with flaky tests - Semaphore](https://semaphore.io/community/tutorials/how-to-deal-with-and-eliminate-flaky-tests)
