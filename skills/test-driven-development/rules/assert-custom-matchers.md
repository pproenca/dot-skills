---
title: Create Custom Matchers for Domain Assertions
impact: MEDIUM
impactDescription: reduces assertion code by 60-80%
tags: assert, custom-matchers, domain, dsl
---

## Create Custom Matchers for Domain Assertions

For frequently-tested domain concepts, create custom matchers that express intent clearly and provide helpful failure messages.

**Incorrect (repeated complex assertions):**

```typescript
test('creates valid order', () => {
  const order = createOrder(orderData)

  // Repeated validation logic in every test
  expect(order.id).toMatch(/^ORD-\d{8}$/)
  expect(order.status).toBe('pending')
  expect(order.items.length).toBeGreaterThan(0)
  expect(order.total).toBeGreaterThan(0)
  expect(order.createdAt).toBeInstanceOf(Date)
})

test('checkout produces valid order', () => {
  const order = await checkout(cart)

  // Same checks duplicated
  expect(order.id).toMatch(/^ORD-\d{8}$/)
  expect(order.status).toBe('pending')
  expect(order.items.length).toBeGreaterThan(0)
  expect(order.total).toBeGreaterThan(0)
  expect(order.createdAt).toBeInstanceOf(Date)
})
```

**Correct (custom domain matcher):**

```typescript
// test-utils/matchers.ts
expect.extend({
  toBeValidOrder(received: unknown) {
    const order = received as Order
    const errors: string[] = []

    if (!order.id?.match(/^ORD-\d{8}$/)) {
      errors.push(`Invalid order ID: ${order.id}`)
    }
    if (order.status !== 'pending') {
      errors.push(`Expected status 'pending', got '${order.status}'`)
    }
    if (!order.items?.length) {
      errors.push('Order has no items')
    }
    if (!order.total || order.total <= 0) {
      errors.push(`Invalid total: ${order.total}`)
    }

    return {
      pass: errors.length === 0,
      message: () => errors.join('\n')
    }
  }
})

// Clean, expressive tests
test('creates valid order', () => {
  const order = createOrder(orderData)
  expect(order).toBeValidOrder()
})

test('checkout produces valid order', () => {
  const order = await checkout(cart)
  expect(order).toBeValidOrder()
})
```

**Good candidates for custom matchers:**
- Domain object validation
- Date/time comparisons
- Complex object structure checks
- API response validation
- State machine transitions

Reference: [Jest Custom Matchers](https://jestjs.io/docs/expect#expectextendmatchers)
