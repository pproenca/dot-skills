---
title: Use Humble Objects at Architectural Boundaries
impact: MEDIUM-HIGH
impactDescription: maximizes testable code, isolates hard-to-test parts
tags: bound, humble-object, testing, boundaries
---

## Use Humble Objects at Architectural Boundaries

The Humble Object pattern separates hard-to-test behaviors from easy-to-test behaviors. The "humble" part contains minimal logic and is hard to test; the substantial logic goes in a testable component.

**Incorrect (logic mixed with hard-to-test framework code):**

```typescript
// React component with business logic
function OrderSummary({ orderId }: Props) {
  const [order, setOrder] = useState<Order | null>(null)
  const [discount, setDiscount] = useState<number>(0)

  useEffect(() => {
    fetch(`/api/orders/${orderId}`)
      .then(r => r.json())
      .then(data => {
        setOrder(data)
        // Business logic in component - hard to test
        if (data.items.length > 5) {
          setDiscount(data.total * 0.1)
        } else if (data.customer.tier === 'gold') {
          setDiscount(data.total * 0.05)
        }
      })
  }, [orderId])

  const finalTotal = order ? order.total - discount : 0

  return (
    <div>
      <span>Subtotal: ${order?.total}</span>
      <span>Discount: ${discount}</span>
      <span>Total: ${finalTotal}</span>
    </div>
  )
}

// Testing requires React Testing Library + mocked fetch
```

**Correct (humble view + testable presenter):**

```typescript
// Presenter - pure function, easy to test
interface OrderViewModel {
  subtotal: string
  discount: string
  total: string
  hasDiscount: boolean
}

function presentOrder(order: Order): OrderViewModel {
  const discount = calculateDiscount(order)
  const finalTotal = order.total - discount

  return {
    subtotal: formatCurrency(order.total),
    discount: formatCurrency(discount),
    total: formatCurrency(finalTotal),
    hasDiscount: discount > 0
  }
}

function calculateDiscount(order: Order): number {
  if (order.items.length > 5) return order.total * 0.1
  if (order.customer.tier === 'gold') return order.total * 0.05
  return 0
}

// Humble view - no logic, just renders data
function OrderSummary({ viewModel }: { viewModel: OrderViewModel }) {
  return (
    <div>
      <span>Subtotal: {viewModel.subtotal}</span>
      {viewModel.hasDiscount && <span>Discount: {viewModel.discount}</span>}
      <span>Total: {viewModel.total}</span>
    </div>
  )
}

// Container handles data fetching - also humble
function OrderSummaryContainer({ orderId }: Props) {
  const { data: order } = useQuery(['order', orderId], fetchOrder)
  if (!order) return <Loading />
  return <OrderSummary viewModel={presentOrder(order)} />
}

// Test presenter without React
test('applies bulk discount for 6+ items', () => {
  const order = { items: [1,2,3,4,5,6], total: 100, customer: { tier: 'standard' } }
  const vm = presentOrder(order)
  expect(vm.discount).toBe('$10.00')
})
```

**Benefits:**
- Business logic tested with simple unit tests
- UI tests only verify rendering, not logic
- 90%+ of logic covered by fast tests

Reference: [Clean Architecture - Humble Object Pattern](https://www.oreilly.com/library/view/clean-architecture-a/9780134494272/ch23.xhtml)
