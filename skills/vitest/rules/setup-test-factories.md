---
title: Use Test Factories for Complex Test Data
impact: MEDIUM
impactDescription: Reduces test setup boilerplate by 60% and improves test readability
tags: setup, factories, test-data, fixtures, maintainability
---

## Use Test Factories for Complex Test Data

Hardcoded test data is verbose, repetitive, and hard to maintain. Factories create test objects with sensible defaults while allowing tests to override only the fields they care about.

**Incorrect (hardcoded test data):**

```typescript
import { describe, it, expect } from 'vitest'

describe('OrderService', () => {
  it('should calculate total for single item', () => {
    const order = {
      id: '123',
      customerId: 'cust-1',
      items: [{ productId: 'prod-1', name: 'Widget', price: 10, quantity: 1 }],
      status: 'pending',
      createdAt: new Date(),
      updatedAt: new Date(),
      shippingAddress: { street: '123 Main St', city: 'NYC', zip: '10001' },
    }
    expect(service.calculateTotal(order)).toBe(10)
  })

  it('should calculate total for multiple items', () => {
    // Same verbose object with minor changes
    const order = {
      id: '456',
      customerId: 'cust-2',
      items: [
        { productId: 'prod-1', name: 'Widget', price: 10, quantity: 2 },
        { productId: 'prod-2', name: 'Gadget', price: 20, quantity: 1 },
      ],
      status: 'pending',
      createdAt: new Date(),
      updatedAt: new Date(),
      shippingAddress: { street: '456 Oak Ave', city: 'LA', zip: '90001' },
    }
    expect(service.calculateTotal(order)).toBe(40)
  })
})
```

**Correct (using factories):**

```typescript
import { describe, it, expect } from 'vitest'

// Factory with sensible defaults
function createOrder(overrides: Partial<Order> = {}): Order {
  return {
    id: crypto.randomUUID(),
    customerId: 'test-customer',
    items: [],
    status: 'pending',
    createdAt: new Date(),
    updatedAt: new Date(),
    shippingAddress: createAddress(),
    ...overrides,
  }
}

function createOrderItem(overrides: Partial<OrderItem> = {}): OrderItem {
  return {
    productId: crypto.randomUUID(),
    name: 'Test Product',
    price: 10,
    quantity: 1,
    ...overrides,
  }
}

describe('OrderService', () => {
  it('should calculate total for single item', () => {
    const order = createOrder({
      items: [createOrderItem({ price: 10, quantity: 1 })],
    })
    expect(service.calculateTotal(order)).toBe(10)
  })

  it('should calculate total for multiple items', () => {
    const order = createOrder({
      items: [
        createOrderItem({ price: 10, quantity: 2 }),
        createOrderItem({ price: 20, quantity: 1 }),
      ],
    })
    expect(service.calculateTotal(order)).toBe(40)
  })
})
```

**Benefits:**
- Tests focus on what matters
- Less boilerplate to maintain
- Easy to create variations

Reference: [Test Data Builders Pattern](https://vitest.dev/guide/test-context)
