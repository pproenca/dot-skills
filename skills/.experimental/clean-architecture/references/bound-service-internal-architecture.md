---
title: Services Must Have Internal Clean Architecture
impact: MEDIUM-HIGH
impactDescription: microservices don't replace architecture, they require it
tags: bound, services, microservices, internal
---

## Services Must Have Internal Clean Architecture

Breaking a monolith into microservices doesn't solve architectural problems. Each service still needs internal architecture. Services are a deployment option, not an architecture.

**Incorrect (microservices as architecture replacement):**

```text
"We use microservices architecture"

┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│  order-service  │  │  user-service   │  │ payment-service │
│                 │  │                 │  │                 │
│  routes.js      │  │  routes.js      │  │  routes.js      │
│  database.js    │  │  database.js    │  │  database.js    │
│  helpers.js     │  │  helpers.js     │  │  helpers.js     │
│                 │  │                 │  │                 │
│  (No layers,    │  │  (No layers,    │  │  (No layers,    │
│   no boundaries,│  │   no boundaries,│  │   no boundaries,│
│   just smaller  │  │   just smaller  │  │   just smaller  │
│   messes)       │  │   messes)       │  │   messes)       │
└─────────────────┘  └─────────────────┘  └─────────────────┘

# Result: Distributed monolith
# All the downsides of microservices (network, deployment, consistency)
# None of the benefits (each service still a tangled mess)
```

**Correct (clean architecture within each service):**

```text
┌───────────────────────────────────────────────────────────┐
│                      order-service                         │
│  ┌─────────────────────────────────────────────────────┐  │
│  │                      domain/                         │  │
│  │   Order.ts  OrderLine.ts  OrderStatus.ts            │  │
│  └─────────────────────────────────────────────────────┘  │
│  ┌─────────────────────────────────────────────────────┐  │
│  │                   application/                       │  │
│  │   PlaceOrderUseCase.ts                               │  │
│  │   ports/                                             │  │
│  │     OrderRepository.ts                               │  │
│  │     PaymentGateway.ts  ← calls payment-service       │  │
│  └─────────────────────────────────────────────────────┘  │
│  ┌─────────────────────────────────────────────────────┐  │
│  │                  infrastructure/                     │  │
│  │   PostgresOrderRepository.ts                         │  │
│  │   HttpPaymentGateway.ts  → payment-service API       │  │
│  │   KafkaEventPublisher.ts                             │  │
│  └─────────────────────────────────────────────────────┘  │
│  ┌─────────────────────────────────────────────────────┐  │
│  │                   interface/                         │  │
│  │   OrderController.ts                                 │  │
│  │   OrderEventHandler.ts                               │  │
│  └─────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────┘

# Each service has:
# - Domain layer with business rules
# - Application layer with use cases and ports
# - Infrastructure layer implementing ports
# - Clean dependency direction within service
```

**Cross-service communication:**
```typescript
// application/ports/PaymentGateway.ts
interface PaymentGateway {
  charge(amount: Money, method: PaymentMethod): Promise<PaymentResult>
}

// infrastructure/HttpPaymentGateway.ts
class HttpPaymentGateway implements PaymentGateway {
  async charge(amount: Money, method: PaymentMethod): Promise<PaymentResult> {
    // Calls payment-service over HTTP
    // Service boundary is an infrastructure detail
    const response = await fetch('http://payment-service/charge', { ... })
    return this.mapResponse(response)
  }
}
```

**Benefits:**
- Services testable without other services
- Can extract or merge services without rewriting business logic
- Network boundaries don't compromise internal architecture

Reference: [Clean Architecture - Services: Great and Small](https://www.oreilly.com/library/view/clean-architecture-a/9780134494272/ch27.xhtml)
