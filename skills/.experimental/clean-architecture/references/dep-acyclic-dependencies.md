---
title: Eliminate Cyclic Dependencies Between Components
impact: CRITICAL
impactDescription: prevents ripple effects, enables independent deployment
tags: dep, cycles, acyclic, components
---

## Eliminate Cyclic Dependencies Between Components

The dependency graph must be a Directed Acyclic Graph (DAG). Cycles create ripple effects where changes propagate unpredictably through the system.

**Incorrect (cyclic dependency):**

```typescript
// modules/orders/OrderService.ts
import { CustomerService } from '../customers/CustomerService'

export class OrderService {
  constructor(private customers: CustomerService) {}

  async createOrder(customerId: string) {
    const customer = await this.customers.findById(customerId)
    // ...
  }
}

// modules/customers/CustomerService.ts
import { OrderService } from '../orders/OrderService'  // Cycle!

export class CustomerService {
  constructor(private orders: OrderService) {}

  async getCustomerWithOrders(customerId: string) {
    const orders = await this.orders.findByCustomer(customerId)
    // ...
  }
}
// Neither module can be deployed or tested independently
```

**Correct (break cycle with dependency inversion):**

```typescript
// modules/orders/ports/CustomerProvider.ts
export interface CustomerProvider {
  findById(id: string): Promise<Customer>
}

// modules/orders/OrderService.ts
import { CustomerProvider } from './ports/CustomerProvider'

export class OrderService {
  constructor(private customers: CustomerProvider) {}

  async createOrder(customerId: string) {
    const customer = await this.customers.findById(customerId)
    // ...
  }
}

// modules/customers/CustomerService.ts
// No import from orders module

export class CustomerService implements CustomerProvider {
  // Implements the interface defined in orders module
}

// modules/customers/adapters/OrderAdapter.ts
import { OrderService } from '../../orders/OrderService'

export class CustomerOrderAdapter {
  constructor(private orders: OrderService) {}

  async getOrdersForCustomer(customerId: string) {
    return this.orders.findByCustomer(customerId)
  }
}
```

**Alternative (extract shared abstraction):**

Create a new component that both depend on, breaking the cycle into a DAG.

Reference: [Clean Architecture - Acyclic Dependencies Principle](https://www.oreilly.com/library/view/clean-architecture-a/9780134494272/ch14.xhtml)
