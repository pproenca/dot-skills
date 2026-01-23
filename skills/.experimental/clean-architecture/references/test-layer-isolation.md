---
title: Test Each Layer in Isolation
impact: LOW-MEDIUM
impactDescription: fast feedback, precise failure location
tags: test, isolation, layers, unit
---

## Test Each Layer in Isolation

Each architectural layer should be testable independently. Domain tests need no infrastructure. Use case tests need no web framework. This enables fast, focused testing.

**Incorrect (everything tested through API):**

```typescript
// All tests go through HTTP - slow, imprecise failures
describe('Order API', () => {
  let app: Express
  let db: Database

  beforeEach(async () => {
    db = await Database.connect()
    await db.migrate()
    await db.seed()
    app = createApp(db)
  })

  afterEach(async () => {
    await db.clean()
    await db.close()
  })

  it('rejects order with insufficient inventory', async () => {
    // 500ms+ per test
    const response = await request(app)
      .post('/orders')
      .send({ items: [{ productId: 'p1', quantity: 1000 }] })

    expect(response.status).toBe(400)
    expect(response.body.error).toBe('Insufficient inventory')
  })

  // 50 more tests like this - test suite takes 5 minutes
  // When one fails, unclear if it's domain, use case, or HTTP issue
})
```

**Correct (layered testing):**

```typescript
// Domain layer tests - instant, no dependencies
describe('Order', () => {
  it('calculates total from items', () => {
    const order = new Order()
    order.addItem(new Product('p1', Money.dollars(10)), 2)
    order.addItem(new Product('p2', Money.dollars(5)), 1)

    expect(order.total).toEqual(Money.dollars(25))
  })

  it('prevents adding item with zero quantity', () => {
    const order = new Order()

    expect(() => order.addItem(product, 0)).toThrow(InvalidQuantityError)
  })
})

// Use case tests - fast, test doubles for ports
describe('PlaceOrderUseCase', () => {
  it('rejects order when inventory insufficient', () => {
    const orders = new InMemoryOrderRepository()
    const inventory = new FakeInventory({ 'p1': 5 })  // Only 5 in stock
    const useCase = new PlaceOrderUseCase(orders, inventory)

    const result = useCase.execute({
      items: [{ productId: 'p1', quantity: 10 }]  // Want 10
    })

    expect(result.isFailure).toBe(true)
    expect(result.error).toBe('INSUFFICIENT_INVENTORY')
  })
})

// Infrastructure tests - verify adapters work correctly
describe('PostgresOrderRepository', () => {
  it('persists and retrieves order', async () => {
    const repo = new PostgresOrderRepository(testDb)
    const order = createTestOrder()

    await repo.save(order)
    const retrieved = await repo.findById(order.id)

    expect(retrieved).toEqual(order)
  })
})

// API tests - few, verify wiring only
describe('POST /orders', () => {
  it('returns 201 when order placed successfully', async () => {
    // Most logic tested above; this verifies HTTP wiring
    const response = await request(app)
      .post('/orders')
      .send(validOrderPayload)

    expect(response.status).toBe(201)
    expect(response.body).toHaveProperty('orderId')
  })
})
```

**Test pyramid:**
```text
        /\
       /  \     E2E: ~5 tests (slow, expensive)
      /----\
     /      \   Integration: ~20 tests (medium)
    /--------\
   /          \ Unit: ~200 tests (fast, cheap)
  /____________\
```

Reference: [The Test Pyramid](https://martinfowler.com/articles/practical-test-pyramid.html)
