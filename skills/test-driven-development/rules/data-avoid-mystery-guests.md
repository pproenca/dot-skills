---
title: Avoid Mystery Guests
impact: HIGH
impactDescription: 2-3× faster test comprehension
tags: data, mystery-guest, readability, fixtures
---

## Avoid Mystery Guests

All test data should be visible within the test or clearly referenced. Hidden data loaded from fixtures or external files makes tests impossible to understand in isolation.

**Incorrect (mystery guest from fixtures):**

```typescript
// fixtures/users.json - somewhere else in the codebase
// { "testUser": { "id": "u1", "role": "admin", "permissions": ["read", "write", "delete"] } }

test('admin can delete posts', async () => {
  // Where does testUser come from? What role? What permissions?
  const result = await deletePost('post-123', fixtures.testUser)

  expect(result.success).toBe(true)
})

test('user permissions are checked', async () => {
  // Reader must hunt through fixture files to understand
  await expect(deletePost('post-123', fixtures.regularUser))
    .rejects.toThrow('Forbidden')
})
```

**Correct (data visible in test):**

```typescript
test('admin can delete posts', async () => {
  // All relevant information visible
  const admin = createUser({ role: 'admin', permissions: ['delete'] })

  const result = await deletePost('post-123', admin)

  expect(result.success).toBe(true)
})

test('users without delete permission cannot delete posts', async () => {
  const user = createUser({ role: 'member', permissions: ['read'] })

  await expect(deletePost('post-123', user))
    .rejects.toThrow('Forbidden')
})
```

**When fixtures are acceptable:**
- Reference data that never changes (country codes, currencies)
- Large datasets for performance testing
- Seed data for integration tests (clearly documented)

**Signs of mystery guests:**
- Test fails and you have to search for data definitions
- Changing a fixture breaks unrelated tests
- Test name doesn't explain why a particular fixture is used

Reference: [Software Testing Anti-patterns - Codepipes](https://blog.codepipes.com/testing/software-testing-antipatterns.html)
