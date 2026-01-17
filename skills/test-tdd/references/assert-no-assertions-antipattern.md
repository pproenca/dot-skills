---
title: Every Test Must Have Assertions
impact: MEDIUM
impactDescription: prevents false passing tests
tags: assert, assertions, verification, completeness
---

## Every Test Must Have Assertions

A test without assertions always passes, providing false confidence. Every test must verify expected outcomes through explicit assertions.

**Incorrect (no assertions):**

```typescript
test('processes payment', async () => {
  const order = createOrder({ total: 100 })
  const payment = createPayment({ orderId: order.id, amount: 100 })

  // Calls the function but doesn't verify anything
  await paymentService.process(payment)
  // Test passes even if process() does nothing
})

test('user registration flow', async () => {
  const userData = { email: 'test@example.com', password: 'secret123' }

  const user = await userService.register(userData)
  await emailService.sendWelcome(user.id)
  await analyticsService.trackSignup(user.id)

  // Multiple operations, zero verification
  // Could silently fail and test still passes
})
```

**Correct (explicit assertions):**

```typescript
test('processes payment and updates order status', async () => {
  const order = createOrder({ total: 100, status: 'pending' })
  const payment = createPayment({ orderId: order.id, amount: 100 })

  await paymentService.process(payment)

  const updatedOrder = await orderService.getById(order.id)
  expect(updatedOrder.status).toBe('paid')
  expect(updatedOrder.paidAt).toBeDefined()
})

test('registration creates user and sends welcome email', async () => {
  const mockEmailService = { sendWelcome: jest.fn() }
  const userService = new UserService({ emailService: mockEmailService })

  const user = await userService.register({
    email: 'test@example.com',
    password: 'secret123'
  })

  expect(user.id).toBeDefined()
  expect(user.email).toBe('test@example.com')
  expect(mockEmailService.sendWelcome).toHaveBeenCalledWith(user.id)
})
```

**Common assertion-free antipatterns:**
- "Smoke tests" that just call methods
- Tests that only set up data
- Tests that verify internal state through logging

Reference: [Software Testing Anti-patterns - Codepipes](https://blog.codepipes.com/testing/software-testing-antipatterns.html)
