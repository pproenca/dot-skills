---
title: Use Setup and Teardown Hooks Appropriately
impact: MEDIUM
impactDescription: reduces setup duplication by 30-50%
tags: org, setup, teardown, beforeEach, afterEach
---

## Use Setup and Teardown Hooks Appropriately

Use `beforeEach`/`afterEach` for common setup that applies to all tests in a block. Avoid hooks when they obscure test behavior or create hidden dependencies.

**Incorrect (hooks hide test behavior):**

```typescript
describe('OrderService', () => {
  let service: OrderService
  let user: User
  let product: Product
  let cart: Cart

  beforeEach(async () => {
    service = new OrderService()
    user = await createUser({ tier: 'premium' })  // Why premium?
    product = await createProduct({ price: 100 })  // Why 100?
    cart = await createCart({ userId: user.id })
    await cart.addItem(product.id, 2)  // Why 2 items?
  })

  test('calculates total', () => {
    // Reader must check beforeEach to understand test
    const total = service.calculateTotal(cart)
    expect(total).toBe(200)  // Unexplained number, unclear where it comes from
  })
})
```

**Correct (hooks for infrastructure, tests show data):**

```typescript
describe('OrderService', () => {
  let service: OrderService

  // Hook for infrastructure only
  beforeEach(() => {
    service = new OrderService()
  })

  afterEach(async () => {
    await cleanupTestOrders()
  })

  test('calculates total from item prices and quantities', () => {
    // Test shows all relevant data
    const cart = createCart({
      items: [
        { productId: 'p1', price: 100, quantity: 2 },
        { productId: 'p2', price: 50, quantity: 1 }
      ]
    })

    const total = service.calculateTotal(cart)

    expect(total).toBe(250)  // 100*2 + 50*1, reader can verify
  })

  test('applies premium discount', () => {
    const cart = createCart({
      items: [{ productId: 'p1', price: 100, quantity: 1 }],
      userTier: 'premium'  // Explicit: test is about premium discount
    })

    const total = service.calculateTotal(cart)

    expect(total).toBe(90)  // 10% premium discount
  })
})
```

**Guidelines:**
- Use hooks for: service instantiation, database cleanup, mock resets
- Avoid hooks for: test-specific data, scenario setup
- If a test needs different setup, create a nested describe block

Reference: [Jest Setup and Teardown](https://jestjs.io/docs/setup-teardown)
