---
title: Use Dependency Injection
impact: CRITICAL
impactDescription: enables testing and reduces coupling by 70-90%
tags: couple, dependency-injection, testability, solid
---

## Use Dependency Injection

Pass dependencies to a class rather than creating them internally. This makes classes testable and loosely coupled.

**Incorrect (hard-coded dependencies):**

```typescript
class OrderService {
  private database = new PostgresDatabase()  // Hard-coded dependency
  private emailService = new SendGridEmailService()  // Can't test without real SendGrid
  private logger = new FileLogger('/var/log/app.log')  // Writes to real file

  async createOrder(orderData: OrderData): Promise<Order> {
    const order = await this.database.insert('orders', orderData)
    await this.emailService.send(order.customerEmail, 'Order Confirmed', order.id)
    this.logger.info(`Order created: ${order.id}`)
    return order
  }
}

// Testing requires real database, email service, and filesystem
const service = new OrderService()  // No way to substitute dependencies
```

**Correct (injected dependencies):**

```typescript
interface Database {
  insert(table: string, data: unknown): Promise<{ id: string }>
}

interface EmailService {
  send(to: string, subject: string, body: string): Promise<void>
}

interface Logger {
  info(message: string): void
}

class OrderService {
  constructor(
    private database: Database,
    private emailService: EmailService,
    private logger: Logger
  ) {}

  async createOrder(orderData: OrderData): Promise<Order> {
    const order = await this.database.insert('orders', orderData)
    await this.emailService.send(order.customerEmail, 'Order Confirmed', order.id)
    this.logger.info(`Order created: ${order.id}`)
    return order
  }
}

// Easy to test with mocks
const mockDatabase = { insert: jest.fn().mockResolvedValue({ id: '123' }) }
const mockEmail = { send: jest.fn() }
const mockLogger = { info: jest.fn() }
const service = new OrderService(mockDatabase, mockEmail, mockLogger)
```

**Benefits:**
- Unit tests run without external services
- Easy to swap implementations (PostgreSQL → MongoDB)
- Dependencies are explicit in the constructor signature

Reference: [Dependency Inversion Principle](https://en.wikipedia.org/wiki/Dependency_inversion_principle)
