---
title: Use Factories for Test Data Creation
impact: HIGH
impactDescription: reduces test setup code by 60-80%
tags: data, factories, setup, maintainability
---

## Use Factories for Test Data Creation

Create factory functions that generate test objects with sensible defaults. Override only the properties relevant to each test, keeping setup minimal and focused.

**Incorrect (verbose inline object creation):**

```typescript
test('calculates order total with discount', () => {
  const order = {
    id: '123',
    userId: 'user-456',
    items: [
      { id: 'item-1', name: 'Widget', price: 100, quantity: 2 },
      { id: 'item-2', name: 'Gadget', price: 50, quantity: 1 }
    ],
    discount: 0.1,
    status: 'pending',
    createdAt: new Date('2024-01-01'),
    updatedAt: new Date('2024-01-01'),
    shippingAddress: {
      street: '123 Main St',
      city: 'Springfield',
      zipCode: '12345',
      country: 'USA'
    }
  }
  // 20 lines of setup for a test about discount calculation
  expect(calculateTotal(order)).toBe(225)  // (200 + 50) * 0.9
})
```

**Correct (factory with relevant overrides):**

```typescript
// factories/order.ts
function createOrder(overrides: Partial<Order> = {}): Order {
  return {
    id: `order-${Math.random().toString(36).slice(2)}`,
    userId: 'default-user',
    items: [],
    discount: 0,
    status: 'pending',
    createdAt: new Date(),
    updatedAt: new Date(),
    shippingAddress: createAddress(),
    ...overrides
  }
}

function createOrderItem(overrides: Partial<OrderItem> = {}): OrderItem {
  return {
    id: `item-${Math.random().toString(36).slice(2)}`,
    name: 'Test Product',
    price: 10,
    quantity: 1,
    ...overrides
  }
}

// Test focuses only on relevant data
test('calculates order total with discount', () => {
  const order = createOrder({
    items: [
      createOrderItem({ price: 100, quantity: 2 }),
      createOrderItem({ price: 50, quantity: 1 })
    ],
    discount: 0.1
  })

  expect(calculateTotal(order)).toBe(225)
})
```

**Benefits:**
- Tests show only relevant data
- Single place to update when model changes
- Consistent default values across tests
- Readable test intent

Reference: [Test Factories - Radan Skoric](https://radanskoric.com/articles/test-factories-principal-of-minimal-defaults)
