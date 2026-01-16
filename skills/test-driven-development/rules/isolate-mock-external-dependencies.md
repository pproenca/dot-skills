---
title: Mock External Dependencies
impact: HIGH
impactDescription: makes tests 10-100× faster
tags: isolate, mocking, dependencies, external-services
---

## Mock External Dependencies

Replace external systems (databases, APIs, file systems) with test doubles. This makes tests fast, deterministic, and independent of external state.

**Incorrect (using real external dependencies):**

```typescript
test('sends welcome email to new user', async () => {
  const user = await userService.register({
    email: 'test@example.com',
    name: 'Alice'
  })

  // Actually sends email - slow, unreliable, costs money
  // Fails if email server is down
  // Clutters real inbox or spam folder
  const emails = await checkEmailInbox('test@example.com')
  expect(emails).toContainEqual(expect.objectContaining({
    subject: 'Welcome to our platform!'
  }))
})
```

**Correct (mock external dependency):**

```typescript
test('sends welcome email to new user', async () => {
  // Arrange
  const mockEmailService = {
    send: jest.fn().mockResolvedValue({ success: true })
  }
  const userService = new UserService({ emailService: mockEmailService })

  // Act
  await userService.register({
    email: 'test@example.com',
    name: 'Alice'
  })

  // Assert
  expect(mockEmailService.send).toHaveBeenCalledWith({
    to: 'test@example.com',
    subject: 'Welcome to our platform!',
    body: expect.stringContaining('Alice')
  })
})
```

**What to mock:**
- HTTP APIs and network calls
- Databases
- File system operations
- Email/SMS services
- Third-party SDKs
- System clock and randomness

**What NOT to mock:**
- The code under test itself
- Simple value objects
- Pure utility functions

Reference: [Isolating Dependencies - Code Magazine](https://www.codemag.com/article/0906061/Isolating-Dependencies-in-Tests-Using-Mocks-and-Stubs)
