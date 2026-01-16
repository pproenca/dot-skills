---
title: Keep Test Setup Minimal
impact: HIGH
impactDescription: 2-5× faster test execution and comprehension
tags: data, setup, minimal, focused
---

## Keep Test Setup Minimal

Include only the data necessary for the specific test. Excessive setup obscures the test's purpose and slows execution.

**Incorrect (excessive setup):**

```typescript
test('validates email format', () => {
  // Full user object when only email matters
  const user = {
    id: '123',
    firstName: 'John',
    lastName: 'Doe',
    email: 'invalid-email',
    dateOfBirth: new Date('1990-01-01'),
    address: {
      street: '123 Main St',
      city: 'Springfield',
      state: 'IL',
      zipCode: '12345'
    },
    preferences: {
      newsletter: true,
      notifications: { email: true, sms: false }
    },
    createdAt: new Date(),
    updatedAt: new Date()
  }

  const errors = validateUser(user)

  expect(errors).toContain('Invalid email format')
})
```

**Correct (minimal setup):**

```typescript
test('validates email format', () => {
  // Only email is relevant to this test
  const user = createUser({ email: 'invalid-email' })

  const errors = validateUser(user)

  expect(errors).toContain('Invalid email format')
})

// Or even simpler if testing just the email validator
test('rejects email without @ symbol', () => {
  const result = isValidEmail('invalidemail')

  expect(result).toBe(false)
})
```

**Guidelines:**
- If a property isn't in the test name, question whether it's needed
- Let factories provide default values for irrelevant properties
- Prefer testing smaller units that need less setup
- Complex setup often indicates design issues in production code

Reference: [Rails Testing Antipatterns - Semaphore](https://semaphore.io/blog/2014/01/14/rails-testing-antipatterns-fixtures-and-factories.html)
