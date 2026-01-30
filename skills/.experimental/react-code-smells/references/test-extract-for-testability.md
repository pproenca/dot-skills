---
title: Extract Logic to Hooks for Testability
impact: MEDIUM
impactDescription: enables testing logic without rendering, 3× faster tests
tags: test, hooks, extraction, logic, testability
---

## Extract Logic to Hooks for Testability

Complex logic buried in components is hard to test. Extract to custom hooks for isolated, fast testing.

**Code Smell Indicators:**
- Tests render full component to test one calculation
- Same logic copy-pasted to multiple components
- Component tests are slow and complex
- Hard to test edge cases in logic

**Incorrect (logic buried in component):**

```tsx
function ShoppingCart({ items, taxRate, discountCode }) {
  const [appliedDiscount, setAppliedDiscount] = useState(null)

  // Complex logic buried in component
  const subtotal = items.reduce((sum, item) => sum + item.price * item.quantity, 0)

  const discountAmount = useMemo(() => {
    if (!appliedDiscount) return 0
    if (appliedDiscount.type === 'percentage') {
      return subtotal * (appliedDiscount.value / 100)
    }
    if (appliedDiscount.type === 'fixed') {
      return Math.min(appliedDiscount.value, subtotal)
    }
    return 0
  }, [appliedDiscount, subtotal])

  const tax = (subtotal - discountAmount) * taxRate
  const total = subtotal - discountAmount + tax

  async function applyDiscount() {
    const discount = await validateDiscountCode(discountCode)
    setAppliedDiscount(discount)
  }

  return (
    <div>
      <ItemList items={items} />
      <button onClick={applyDiscount}>Apply Discount</button>
      <p>Subtotal: ${subtotal.toFixed(2)}</p>
      <p>Discount: -${discountAmount.toFixed(2)}</p>
      <p>Tax: ${tax.toFixed(2)}</p>
      <p>Total: ${total.toFixed(2)}</p>
    </div>
  )
}

// Testing requires rendering entire component
test('calculates discount', async () => {
  // Need to mock API, render component, find text...
  render(<ShoppingCart items={items} taxRate={0.08} discountCode="SAVE10" />)
  // Complex assertions on rendered text...
})
```

**Correct (logic extracted to hook):**

```tsx
// Hook contains all calculation logic
function useCartCalculations(items: CartItem[], taxRate: number) {
  const [appliedDiscount, setAppliedDiscount] = useState<Discount | null>(null)

  const subtotal = useMemo(
    () => items.reduce((sum, item) => sum + item.price * item.quantity, 0),
    [items]
  )

  const discountAmount = useMemo(() => {
    if (!appliedDiscount) return 0
    if (appliedDiscount.type === 'percentage') {
      return subtotal * (appliedDiscount.value / 100)
    }
    if (appliedDiscount.type === 'fixed') {
      return Math.min(appliedDiscount.value, subtotal)
    }
    return 0
  }, [appliedDiscount, subtotal])

  const tax = (subtotal - discountAmount) * taxRate
  const total = subtotal - discountAmount + tax

  const applyDiscount = useCallback(async (code: string) => {
    const discount = await validateDiscountCode(code)
    setAppliedDiscount(discount)
  }, [])

  return { subtotal, discountAmount, tax, total, applyDiscount, appliedDiscount }
}

// Component is thin - just rendering
function ShoppingCart({ items, taxRate, discountCode }) {
  const cart = useCartCalculations(items, taxRate)

  return (
    <div>
      <ItemList items={items} />
      <button onClick={() => cart.applyDiscount(discountCode)}>Apply Discount</button>
      <p>Subtotal: ${cart.subtotal.toFixed(2)}</p>
      <p>Discount: -${cart.discountAmount.toFixed(2)}</p>
      <p>Tax: ${cart.tax.toFixed(2)}</p>
      <p>Total: ${cart.total.toFixed(2)}</p>
    </div>
  )
}

// Test hook directly - fast, focused
test('calculates subtotal from items', () => {
  const items = [
    { id: '1', price: 10, quantity: 2 },
    { id: '2', price: 5, quantity: 3 },
  ]
  const { result } = renderHook(() => useCartCalculations(items, 0.08))

  expect(result.current.subtotal).toBe(35)
})

test('applies percentage discount', () => {
  const items = [{ id: '1', price: 100, quantity: 1 }]
  const { result } = renderHook(() => useCartCalculations(items, 0.08))

  act(() => {
    // Simulate applying discount
    result.current.applyDiscount('SAVE10')
  })

  // After discount is applied (mock the API response)
  expect(result.current.discountAmount).toBe(10)
  expect(result.current.total).toBe(97.2) // (100 - 10) * 1.08
})

test('fixed discount cannot exceed subtotal', () => {
  const items = [{ id: '1', price: 10, quantity: 1 }]
  const { result } = renderHook(() => useCartCalculations(items, 0))

  // Apply $50 discount to $10 cart
  act(() => {
    // Discount is capped at subtotal
  })

  expect(result.current.discountAmount).toBe(10) // Capped
})
```

**Extraction heuristics:**
- Calculations with multiple edge cases → Extract
- State machine logic → Extract
- Async operations with complex flows → Extract
- Anything with > 3 test cases → Consider extracting

Reference: [Testing Custom Hooks](https://react.dev/learn/reusing-logic-with-custom-hooks#testing-custom-hooks)
