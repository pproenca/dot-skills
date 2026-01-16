---
title: Use Specific Assertions
impact: MEDIUM
impactDescription: 2-5× faster debugging from better failure messages
tags: assert, specific, matchers, clarity
---

## Use Specific Assertions

Use the most specific assertion available for the check. Specific assertions provide better failure messages and document expected behavior more clearly.

**Incorrect (generic assertions):**

```typescript
test('filters active users', () => {
  const users = [
    { id: '1', active: true },
    { id: '2', active: false }
  ]

  const result = filterActiveUsers(users)

  // Generic - failure message: "expected true to be false"
  expect(result.length === 1).toBe(true)
  expect(result[0].id === '1').toBe(true)
})

test('user has expected properties', () => {
  const user = getUser('123')

  // Generic - unhelpful failure message
  expect(user !== null).toBe(true)
  expect(typeof user.email === 'string').toBe(true)
})
```

**Correct (specific assertions):**

```typescript
test('filters active users', () => {
  const users = [
    { id: '1', active: true },
    { id: '2', active: false }
  ]

  const result = filterActiveUsers(users)

  // Specific - failure: "expected [array] to have length 1, got 0"
  expect(result).toHaveLength(1)
  // Specific - failure: "expected {id: '2'} to match {id: '1'}"
  expect(result[0]).toMatchObject({ id: '1' })
})

test('user has expected properties', () => {
  const user = getUser('123')

  // Specific - failure: "expected null not to be null"
  expect(user).not.toBeNull()
  // Specific - failure: "expected 123 to be a string"
  expect(user.email).toEqual(expect.any(String))
})
```

**Preferred matchers:**
- `toHaveLength()` over `.length === n`
- `toContain()` over `includes() === true`
- `toMatchObject()` over checking each property
- `toThrow()` over try/catch with boolean
- `toBeGreaterThan()` over `> comparison === true`

Reference: [Jest Expect API](https://jestjs.io/docs/expect)
