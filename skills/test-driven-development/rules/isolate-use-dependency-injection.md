---
title: Use Dependency Injection for Testability
impact: HIGH
impactDescription: enables isolation without hacks
tags: isolate, dependency-injection, design, testability
---

## Use Dependency Injection for Testability

Design code to receive dependencies through constructor or method parameters rather than creating them internally. This enables easy substitution of test doubles.

**Incorrect (hard-coded dependencies):**

```typescript
class OrderService {
  async createOrder(items: Item[]): Promise<Order> {
    // Hard-coded dependency - impossible to test without real database
    const db = new DatabaseConnection()
    const order = await db.insert('orders', { items })

    // Hard-coded dependency - actually sends emails during tests
    const emailer = new EmailService()
    await emailer.send(order.userEmail, 'Order confirmed')

    return order
  }
}

// Test requires real database and email service
test('creates order', async () => {
  const service = new OrderService()
  const order = await service.createOrder([{ id: '1', price: 100 }])
  expect(order).toBeDefined()
  // Flaky, slow, sends real emails
})
```

**Correct (dependencies injected):**

```typescript
interface Database {
  insert(table: string, data: unknown): Promise<{ id: string }>
}

interface Emailer {
  send(to: string, subject: string): Promise<void>
}

class OrderService {
  constructor(
    private db: Database,
    private emailer: Emailer
  ) {}

  async createOrder(items: Item[]): Promise<Order> {
    const order = await this.db.insert('orders', { items })
    await this.emailer.send(order.userEmail, 'Order confirmed')
    return order
  }
}

// Test with injected fakes
test('creates order and sends confirmation', async () => {
  const fakeDb: Database = {
    insert: jest.fn().mockResolvedValue({
      id: 'order-123',
      userEmail: 'test@example.com'
    })
  }
  const fakeEmailer: Emailer = {
    send: jest.fn().mockResolvedValue(undefined)
  }

  const service = new OrderService(fakeDb, fakeEmailer)
  const order = await service.createOrder([{ id: '1', price: 100 }])

  expect(order.id).toBe('order-123')
  expect(fakeEmailer.send).toHaveBeenCalledWith(
    'test@example.com',
    'Order confirmed'
  )
})
```

**Benefits:**
- Tests run without real infrastructure
- Easy to test error conditions
- Clear dependencies in constructor
- Production code receives real implementations

Reference: [Dependency Injection - Tao of Testing](https://jasonpolites.github.io/tao-of-testing/ch3-1.1.html)
