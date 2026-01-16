---
title: Follow the Arrange-Act-Assert Pattern
impact: CRITICAL
impactDescription: makes tests 2-3× more readable
tags: design, aaa, arrange-act-assert, structure
---

## Follow the Arrange-Act-Assert Pattern

Structure every test with three distinct phases: Arrange (setup), Act (execute), Assert (verify). This pattern makes tests predictable and easy to understand.

**Incorrect (phases interleaved):**

```typescript
test('processes order', async () => {
  const user = createUser()
  expect(user.orders).toHaveLength(0)  // Assert before Act

  const product = createProduct({ price: 100 })
  await orderService.addToCart(user.id, product.id)  // Act 1
  expect(await cartService.getItems(user.id)).toHaveLength(1)  // Assert 1

  const order = await orderService.checkout(user.id)  // Act 2
  expect(order.total).toBe(100)  // Assert 2
  expect(order.status).toBe('pending')  // Assert 2 continued

  await paymentService.process(order.id)  // Act 3
  expect(order.status).toBe('paid')  // Assert 3
})
```

**Correct (clear AAA structure):**

```typescript
test('checkout creates order with cart total', async () => {
  // Arrange
  const user = await createUser()
  const product = await createProduct({ price: 100 })
  await cartService.addItem(user.id, product.id)

  // Act
  const order = await orderService.checkout(user.id)

  // Assert
  expect(order.total).toBe(100)
  expect(order.status).toBe('pending')
})

test('processPayment marks order as paid', async () => {
  // Arrange
  const order = await createOrder({ status: 'pending', total: 100 })

  // Act
  await paymentService.process(order.id)

  // Assert
  const updated = await orderService.getById(order.id)
  expect(updated.status).toBe('paid')
})
```

**Guidelines:**
- One Act per test (single method call or user action)
- Assert only the outcomes of that specific Act
- Blank lines between sections improve readability
- Comments (`// Arrange`, `// Act`, `// Assert`) are optional but helpful

Reference: [AAA Pattern in Unit Testing - Semaphore](https://semaphore.io/blog/aaa-pattern-test-automation)
