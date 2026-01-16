---
title: Assert on Error Messages and Types
impact: MEDIUM
impactDescription: prevents false positives from wrong errors
tags: assert, errors, exceptions, specificity
---

## Assert on Error Messages and Types

When testing error conditions, verify both the error type and message. Catching any error isn't enough - the right error must be thrown.

**Incorrect (any error passes):**

```typescript
test('throws on invalid email', () => {
  // Passes if ANY error is thrown, even unrelated ones
  expect(() => createUser({ email: 'invalid' })).toThrow()
})

test('throws on missing required field', async () => {
  // Catches network errors, type errors, anything
  await expect(saveUser({})).rejects.toBeDefined()
})
```

**Correct (specific error assertions):**

```typescript
test('throws ValidationError for invalid email', () => {
  expect(() => createUser({ email: 'invalid' }))
    .toThrow(ValidationError)
})

test('error message indicates invalid email format', () => {
  expect(() => createUser({ email: 'invalid' }))
    .toThrow('Invalid email format')
})

test('throws with specific error details', () => {
  expect(() => createUser({ email: 'invalid' }))
    .toThrow(expect.objectContaining({
      code: 'VALIDATION_ERROR',
      field: 'email'
    }))
})

test('async operation throws NotFoundError', async () => {
  await expect(getUser('nonexistent'))
    .rejects.toThrow(NotFoundError)
})

test('error includes resource identifier', async () => {
  await expect(getUser('user-999'))
    .rejects.toThrow(/user-999/)
})
```

**What to assert:**
- Error class/type when using custom errors
- Error message content (exact or partial match)
- Error code or status when applicable
- Associated data (field name, invalid value)

Reference: [Unit Testing Best Practices - Microsoft Learn](https://learn.microsoft.com/en-us/dotnet/core/testing/unit-testing-best-practices)
