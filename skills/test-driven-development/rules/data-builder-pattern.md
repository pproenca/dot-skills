---
title: Use Builder Pattern for Complex Objects
impact: HIGH
impactDescription: reduces complex setup code by 40-60%
tags: data, builder, complex-objects, fluent
---

## Use Builder Pattern for Complex Objects

For objects with many optional fields or complex construction, use the builder pattern to create readable, flexible test setup.

**Incorrect (unwieldy object construction):**

```typescript
test('processes order with all options', () => {
  const order = {
    id: '123',
    customer: { id: 'c1', name: 'Alice', tier: 'premium' },
    items: [
      { productId: 'p1', quantity: 2, price: 100 },
      { productId: 'p2', quantity: 1, price: 50 }
    ],
    shipping: { method: 'express', address: { city: 'NYC', zip: '10001' } },
    payment: { method: 'card', cardLast4: '1234' },
    discount: { code: 'SAVE10', percent: 10 },
    giftWrap: true,
    giftMessage: 'Happy Birthday!'
  }

  const result = processOrder(order)
  expect(result.total).toBe(225)
})
```

**Correct (fluent builder):**

```typescript
// test-utils/order-builder.ts
class OrderBuilder {
  private order: Partial<Order> = {}

  withCustomer(tier: 'basic' | 'premium' = 'basic'): this {
    this.order.customer = createCustomer({ tier })
    return this
  }

  withItems(...items: Array<{ price: number; quantity?: number }>): this {
    this.order.items = items.map(item =>
      createOrderItem({ price: item.price, quantity: item.quantity ?? 1 })
    )
    return this
  }

  withDiscount(percent: number): this {
    this.order.discount = { code: 'TEST', percent }
    return this
  }

  withExpressShipping(): this {
    this.order.shipping = { method: 'express', address: createAddress() }
    return this
  }

  asGift(message: string): this {
    this.order.giftWrap = true
    this.order.giftMessage = message
    return this
  }

  build(): Order {
    return createOrder(this.order)
  }
}

const anOrder = () => new OrderBuilder()

// Clean, readable test
test('processes order with all options', () => {
  const order = anOrder()
    .withCustomer('premium')
    .withItems({ price: 100, quantity: 2 }, { price: 50 })
    .withDiscount(10)
    .withExpressShipping()
    .asGift('Happy Birthday!')
    .build()

  const result = processOrder(order)

  expect(result.total).toBe(225)
})
```

**When to use builders:**
- Objects with 5+ optional fields
- Complex nested structures
- Multiple valid configurations
- When tests need different combinations of options

Reference: [Effective tests: Creating test data - Dave Development](https://davedevelopment.co.uk/2015/11/11/creating-test-data-with-fixture-factories.html)
