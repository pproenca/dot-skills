---
title: Structure Should Scream the Domain Not the Framework
impact: HIGH
impactDescription: enables understanding at a glance, reveals intent
tags: comp, screaming-architecture, structure, domain
---

## Structure Should Scream the Domain Not the Framework

The folder structure should communicate what the system does, not what framework it uses. Looking at the top-level directories should reveal the business domain.

**Incorrect (framework-oriented structure):**

```text
src/
├── controllers/
│   ├── UserController.ts
│   ├── OrderController.ts
│   └── ProductController.ts
├── services/
│   ├── UserService.ts
│   ├── OrderService.ts
│   └── ProductService.ts
├── repositories/
│   ├── UserRepository.ts
│   ├── OrderRepository.ts
│   └── ProductRepository.ts
├── models/
│   ├── User.ts
│   ├── Order.ts
│   └── Product.ts
└── utils/
    └── helpers.ts

# This screams "MVC framework" not "e-commerce system"
```

**Correct (domain-oriented structure):**

```text
src/
├── ordering/
│   ├── domain/
│   │   ├── Order.ts
│   │   ├── OrderLine.ts
│   │   └── OrderStatus.ts
│   ├── application/
│   │   ├── PlaceOrderUseCase.ts
│   │   ├── CancelOrderUseCase.ts
│   │   └── ports/
│   │       ├── OrderRepository.ts
│   │       └── PaymentGateway.ts
│   └── infrastructure/
│       ├── PostgresOrderRepository.ts
│       └── StripePaymentGateway.ts
├── inventory/
│   ├── domain/
│   ├── application/
│   └── infrastructure/
├── customers/
│   ├── domain/
│   ├── application/
│   └── infrastructure/
└── shared/
    └── kernel/
        ├── Money.ts
        └── EntityId.ts

# This screams "e-commerce with ordering, inventory, customers"
```

**Benefits:**
- New developers understand the domain immediately
- Related code lives together, enabling focused changes
- Frameworks become implementation details, not organizing principles

Reference: [Screaming Architecture](https://blog.cleancoder.com/uncle-bob/2011/09/30/Screaming-Architecture.html)
