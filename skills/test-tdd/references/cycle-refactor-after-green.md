---
title: Refactor Immediately After Green
impact: CRITICAL
impactDescription: prevents technical debt accumulation
tags: cycle, refactor-phase, clean-code, continuous-improvement
---

## Refactor Immediately After Green

The REFACTOR phase is not optional. Once tests pass, immediately clean up both production and test code. Skipping refactoring accumulates technical debt that compounds over time.

**Incorrect (skipping refactor phase):**

```typescript
// Test passes, move on to next feature
test('calculates order total with tax', () => {
  const order = { items: [{ price: 100 }, { price: 50 }], taxRate: 0.1 }
  expect(calculateTotal(order)).toBe(165)
})

// Quick and dirty implementation, "will clean up later"
function calculateTotal(order: Order): number {
  let t = 0
  for (let i = 0; i < order.items.length; i++) {
    t = t + order.items[i].price
  }
  t = t + t * order.taxRate
  return t
}
// Technical debt: unclear variable names, imperative style
```

**Correct (refactor while context is fresh):**

```typescript
test('calculates order total with tax', () => {
  const order = { items: [{ price: 100 }, { price: 50 }], taxRate: 0.1 }
  expect(calculateTotal(order)).toBe(165)
})

// After GREEN, immediately refactor
function calculateTotal(order: Order): number {
  const subtotal = order.items.reduce((sum, item) => sum + item.price, 0)
  const tax = subtotal * order.taxRate
  return subtotal + tax
}
// Clean: descriptive names, functional style, clear intent
```

**The refactor checklist:**
- Rename unclear variables and functions
- Extract repeated code into functions
- Remove duplication in test setup
- Simplify complex conditionals

**Note:** Run tests after each refactoring step to ensure behavior is preserved.

Reference: [Red-Green-Refactor - James Shore](http://www.jamesshore.com/v2/blog/2005/red-green-refactor)
