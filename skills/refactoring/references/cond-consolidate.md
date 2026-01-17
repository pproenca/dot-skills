---
title: Consolidate Duplicate Conditional Fragments
impact: HIGH
impactDescription: reduces code duplication by 30-50%
tags: cond, consolidate, duplication, extract
---

## Consolidate Duplicate Conditional Fragments

When the same code appears in all branches of a conditional, move it outside the conditional. When multiple conditions lead to the same result, combine them.

**Incorrect (duplicated code in branches):**

```typescript
function calculateShipping(order: Order, customer: Customer): number {
  if (customer.isPremium) {
    logShippingCalculation(order.id)  // Duplicated
    const baseRate = getBaseShippingRate(order.destination)  // Duplicated
    return baseRate * 0.5
  } else if (order.total > 100) {
    logShippingCalculation(order.id)  // Duplicated
    const baseRate = getBaseShippingRate(order.destination)  // Duplicated
    return 0
  } else {
    logShippingCalculation(order.id)  // Duplicated
    const baseRate = getBaseShippingRate(order.destination)  // Duplicated
    return baseRate
  }
}

// Another example: multiple conditions with same result
function getDiscount(dayOfWeek: number): number {
  if (dayOfWeek === 0) {
    return 0.1
  }
  if (dayOfWeek === 6) {
    return 0.1
  }
  if (dayOfWeek === 5 && isAfternoon()) {
    return 0.1
  }
  return 0
}
```

**Correct (consolidated logic):**

```typescript
function calculateShipping(order: Order, customer: Customer): number {
  logShippingCalculation(order.id)  // Moved outside
  const baseRate = getBaseShippingRate(order.destination)  // Moved outside

  if (customer.isPremium) {
    return baseRate * 0.5
  }
  if (order.total > 100) {
    return 0
  }
  return baseRate
}

// Consolidated conditions
function getDiscount(dayOfWeek: number): number {
  if (isWeekendOrFridayAfternoon(dayOfWeek)) {
    return 0.1
  }
  return 0
}

function isWeekendOrFridayAfternoon(dayOfWeek: number): boolean {
  const isWeekend = dayOfWeek === 0 || dayOfWeek === 6
  const isFridayAfternoon = dayOfWeek === 5 && isAfternoon()
  return isWeekend || isFridayAfternoon
}
```

**When NOT to consolidate:**
- The duplication is coincidental, not intentional
- The branches may diverge in the future
- Consolidation obscures the intent of each branch

Reference: [Consolidate Conditional Expression](https://refactoring.com/catalog/consolidateConditionalExpression.html)
