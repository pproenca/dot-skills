---
title: Take Small Incremental Steps
impact: CRITICAL
impactDescription: 2-5× faster debugging from smaller change sets
tags: cycle, increments, baby-steps, feedback-loop
---

## Take Small Incremental Steps

Each red-green-refactor cycle should take seconds to minutes, not hours. Small steps provide rapid feedback, reduce debugging time, and make it easy to identify what broke.

**Incorrect (giant leaps):**

```typescript
// One massive test covering entire feature
test('user registration with validation and email', async () => {
  const result = await registerUser({
    email: 'test@example.com',
    password: 'SecurePass123!',
    name: 'John Doe'
  })

  expect(result.success).toBe(true)
  expect(result.user.email).toBe('test@example.com')
  expect(result.user.emailVerified).toBe(false)
  expect(emailService.sendVerification).toHaveBeenCalled()
  expect(await database.users.findByEmail('test@example.com')).toBeDefined()
})

// Then write hundreds of lines to make it pass
// When it fails, unclear which part is broken
```

**Correct (baby steps):**

```typescript
// Step 1: User can be created
test('creates user with email and name', () => {
  const user = createUser({ email: 'test@example.com', name: 'John' })
  expect(user.email).toBe('test@example.com')
})
// Implement, refactor, commit

// Step 2: Password validation
test('rejects weak passwords', () => {
  expect(() => createUser({
    email: 'test@example.com',
    password: '123'
  })).toThrow('Password too weak')
})
// Implement, refactor, commit

// Step 3: Email verification flag
test('new users start with unverified email', () => {
  const user = createUser({ email: 'test@example.com', name: 'John' })
  expect(user.emailVerified).toBe(false)
})
// Implement, refactor, commit

// Each step: ~30 seconds to 2 minutes
```

**Benefits of small steps:**
- Failures are immediately traceable to last change
- Easier to maintain focus and flow
- Can commit after each passing cycle
- Natural breakpoints for review or pause

Reference: [The Cycles of TDD - Clean Coder Blog](http://blog.cleancoder.com/uncle-bob/2014/12/17/TheCyclesOfTDD.html)
