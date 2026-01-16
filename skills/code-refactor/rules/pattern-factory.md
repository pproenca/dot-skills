---
title: Use Factory for Complex Object Creation
impact: MEDIUM-HIGH
impactDescription: reduces duplication by 40-60% and enables isolated testing
tags: pattern, factory, creation, encapsulation
---

## Use Factory for Complex Object Creation

When object creation involves complex logic, validation, or conditional instantiation, encapsulate it in a factory. This separates creation concerns from business logic.

**Incorrect (complex creation scattered throughout codebase):**

```typescript
class OrderService {
  createOrder(data: OrderData): Order {
    // Complex creation logic repeated wherever orders are created
    const items = data.items.map(item => {
      const product = productRepository.find(item.productId)
      if (!product) throw new Error(`Product not found: ${item.productId}`)
      if (product.inventory < item.quantity) {
        throw new Error(`Insufficient inventory for ${product.name}`)
      }
      return new OrderItem(product, item.quantity, product.price)
    })

    const customer = customerRepository.find(data.customerId)
    if (!customer) throw new Error('Customer not found')

    const shippingAddress = customer.addresses.find(a => a.id === data.addressId)
    if (!shippingAddress) throw new Error('Address not found')

    const order = new Order(customer, items, shippingAddress)
    order.calculateTotals()
    return order
  }
}

// Same creation logic duplicated in ImportService, MigrationService, etc.
```

**Correct (factory encapsulates creation):**

```typescript
class OrderFactory {
  constructor(
    private productRepository: ProductRepository,
    private customerRepository: CustomerRepository
  ) {}

  create(data: OrderData): Order {
    const items = this.createOrderItems(data.items)
    const customer = this.getValidatedCustomer(data.customerId)
    const shippingAddress = this.getValidatedAddress(customer, data.addressId)

    const order = new Order(customer, items, shippingAddress)
    order.calculateTotals()
    return order
  }

  private createOrderItems(itemsData: OrderItemData[]): OrderItem[] {
    return itemsData.map(item => {
      const product = this.productRepository.find(item.productId)
      if (!product) throw new Error(`Product not found: ${item.productId}`)
      if (product.inventory < item.quantity) {
        throw new Error(`Insufficient inventory for ${product.name}`)
      }
      return new OrderItem(product, item.quantity, product.price)
    })
  }

  private getValidatedCustomer(customerId: string): Customer {
    const customer = this.customerRepository.find(customerId)
    if (!customer) throw new Error('Customer not found')
    return customer
  }

  private getValidatedAddress(customer: Customer, addressId: string): Address {
    const address = customer.addresses.find(a => a.id === addressId)
    if (!address) throw new Error('Address not found')
    return address
  }
}

// Service is now simple
class OrderService {
  constructor(private orderFactory: OrderFactory) {}

  createOrder(data: OrderData): Order {
    return this.orderFactory.create(data)
  }
}
```

**Benefits:**
- Creation logic centralized and testable
- Easy to create test doubles (TestOrderFactory)
- Services focus on business logic, not object construction

Reference: [Factory Method Pattern](https://refactoring.guru/design-patterns/factory-method)
