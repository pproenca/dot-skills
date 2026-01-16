---
title: Decompose Complex Conditionals
impact: HIGH
impactDescription: reduces cognitive complexity by 40-60%
tags: cond, decompose, readability, extract-function
---

## Decompose Complex Conditionals

Extract complex boolean expressions into well-named functions. The function name documents the business rule.

**Incorrect (complex inline condition):**

```typescript
function calculateDiscount(customer: Customer, order: Order): number {
  if (
    (customer.membershipYears >= 5 && customer.totalPurchases > 10000) ||
    (customer.tier === 'platinum') ||
    (order.items.length >= 10 && order.subtotal > 500 && !order.hasPromotion)
  ) {
    return order.subtotal * 0.2
  }

  if (
    customer.membershipYears >= 2 &&
    customer.totalPurchases > 5000 &&
    order.subtotal > 200
  ) {
    return order.subtotal * 0.1
  }

  return 0
}
```

**Correct (extracted into named predicates):**

```typescript
function calculateDiscount(customer: Customer, order: Order): number {
  if (isEligibleForPremiumDiscount(customer, order)) {
    return order.subtotal * 0.2
  }

  if (isEligibleForStandardDiscount(customer, order)) {
    return order.subtotal * 0.1
  }

  return 0
}

function isEligibleForPremiumDiscount(customer: Customer, order: Order): boolean {
  return isLoyalHighValueCustomer(customer) ||
         isPlatinumMember(customer) ||
         isBulkOrderWithoutPromotion(order)
}

function isLoyalHighValueCustomer(customer: Customer): boolean {
  return customer.membershipYears >= 5 && customer.totalPurchases > 10000
}

function isPlatinumMember(customer: Customer): boolean {
  return customer.tier === 'platinum'
}

function isBulkOrderWithoutPromotion(order: Order): boolean {
  return order.items.length >= 10 && order.subtotal > 500 && !order.hasPromotion
}

function isEligibleForStandardDiscount(customer: Customer, order: Order): boolean {
  return customer.membershipYears >= 2 &&
         customer.totalPurchases > 5000 &&
         order.subtotal > 200
}
```

**Benefits:**
- Business rules are named and documented
- Each predicate can be tested independently
- Changes to eligibility rules are localized

Reference: [Decompose Conditional](https://refactoring.com/catalog/decomposeConditional.html)
