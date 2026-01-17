---
title: Write the Test Before the Implementation
impact: CRITICAL
impactDescription: prevents 40-90% of defects
tags: cycle, red-phase, test-first, tdd-fundamentals
---

## Write the Test Before the Implementation

Writing the test first forces you to think about the API design and expected behavior before writing production code. This leads to better interfaces and catches design issues early.

**Incorrect (implementation first, test as afterthought):**

```typescript
// 1. Write implementation first
function calculateDiscount(price: number, customerType: string): number {
  if (customerType === 'premium') {
    return price * 0.2
  }
  if (customerType === 'regular') {
    return price * 0.1
  }
  return 0
}

// 2. Write test after (often skipped or superficial)
test('calculateDiscount works', () => {
  expect(calculateDiscount(100, 'premium')).toBe(20)
})
// Edge cases forgotten, API already locked in
```

**Correct (test first, implementation follows):**

```typescript
// 1. Write failing test first (RED)
describe('calculateDiscount', () => {
  it('applies 20% discount for premium customers', () => {
    expect(calculateDiscount(100, 'premium')).toBe(20)
  })

  it('applies 10% discount for regular customers', () => {
    expect(calculateDiscount(100, 'regular')).toBe(10)
  })

  it('returns zero discount for unknown customer types', () => {
    expect(calculateDiscount(100, 'unknown')).toBe(0)
  })
})

// 2. Write minimal implementation to pass (GREEN)
function calculateDiscount(price: number, customerType: string): number {
  const discounts: Record<string, number> = { premium: 0.2, regular: 0.1 }
  return price * (discounts[customerType] ?? 0)
}
```

**Benefits:**
- Forces consideration of edge cases before implementation
- Results in more testable, better-designed APIs
- Ensures tests actually verify behavior, not just exercise code

Reference: [Test Driven Development by Kent Beck](https://www.amazon.com/Test-Driven-Development-Kent-Beck/dp/0321146530)
