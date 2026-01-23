---
title: Defer Framework and Database Decisions
impact: MEDIUM-HIGH
impactDescription: preserves optionality, reduces early commitment risk
tags: bound, deferral, decisions, optionality
---

## Defer Framework and Database Decisions

A good architecture allows major decisions about frameworks, databases, and delivery mechanisms to be deferred until the last responsible moment. The longer you wait, the more information you have.

**Incorrect (early commitment to specifics):**

```typescript
// Day 1: "Let's use Prisma with PostgreSQL and Next.js"

// domain/Order.ts - Coupled to Prisma from the start
import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

export async function createOrder(data: OrderInput) {
  // Business logic intertwined with Prisma
  const order = await prisma.order.create({
    data: {
      items: {
        create: data.items.map(item => ({
          productId: item.productId,
          quantity: item.quantity,
          price: item.price
        }))
      },
      total: data.items.reduce((sum, i) => sum + i.price * i.quantity, 0)
    },
    include: { items: true }
  })

  return order
}

// 6 months later: "PostgreSQL doesn't scale for our read patterns,
// we need DynamoDB" - Massive rewrite required
```

**Correct (defer database decision):**

```typescript
// Day 1: Focus on business rules, defer database choice

// domain/Order.ts - Pure business logic
export class Order {
  private items: OrderItem[] = []

  addItem(product: Product, quantity: number): void {
    if (quantity <= 0) throw new InvalidQuantityError()
    this.items.push(new OrderItem(product, quantity))
  }

  calculateTotal(): Money {
    return this.items.reduce(
      (sum, item) => sum.add(item.lineTotal()),
      Money.zero()
    )
  }
}

// application/ports/OrderRepository.ts - Interface only
export interface OrderRepository {
  save(order: Order): Promise<void>
  findById(id: OrderId): Promise<Order | null>
}

// For now: Simple in-memory implementation for testing
// infrastructure/InMemoryOrderRepository.ts
export class InMemoryOrderRepository implements OrderRepository {
  private orders = new Map<string, Order>()

  async save(order: Order): Promise<void> {
    this.orders.set(order.id.value, order)
  }
}

// Later, when you know more: Add real database
// infrastructure/PrismaOrderRepository.ts
// OR
// infrastructure/DynamoOrderRepository.ts
// OR
// infrastructure/MongoOrderRepository.ts

// The domain never changes regardless of database choice
```

**Decisions worth deferring:**
- Database vendor (PostgreSQL vs MongoDB vs DynamoDB)
- ORM choice (Prisma vs TypeORM vs raw SQL)
- Web framework (Express vs Fastify vs Hono)
- Message queue (RabbitMQ vs Kafka vs SQS)
- Cache provider (Redis vs Memcached)

**Benefits:**
- Learn requirements before committing
- Prototype faster with simple implementations
- Switch vendors without domain rewrites

Reference: [Clean Architecture - The Database is a Detail](https://www.oreilly.com/library/view/clean-architecture-a/9780134494272/ch30.xhtml)
