---
title: Replace Nested Conditionals with Guard Clauses
impact: HIGH
impactDescription: reduces nesting depth and cognitive load by 50-70%
tags: cond, guard-clause, early-return, nesting
---

## Replace Nested Conditionals with Guard Clauses

Deep nesting makes code hard to follow. Use guard clauses to handle edge cases early and keep the main logic at the top level.

**Incorrect (deeply nested conditionals):**

```typescript
function processPayment(order: Order, user: User): PaymentResult {
  if (order !== null) {
    if (order.items.length > 0) {
      if (user !== null) {
        if (user.paymentMethod !== null) {
          if (order.total <= user.creditLimit) {
            // Finally, the actual business logic
            const payment = chargePayment(user.paymentMethod, order.total)
            order.status = 'paid'
            return { success: true, transactionId: payment.id }
          } else {
            return { success: false, error: 'Credit limit exceeded' }
          }
        } else {
          return { success: false, error: 'No payment method' }
        }
      } else {
        return { success: false, error: 'User required' }
      }
    } else {
      return { success: false, error: 'Empty order' }
    }
  } else {
    return { success: false, error: 'Order required' }
  }
}
```

**Correct (guard clauses with early return):**

```typescript
function processPayment(order: Order, user: User): PaymentResult {
  if (!order) {
    return { success: false, error: 'Order required' }
  }
  if (order.items.length === 0) {
    return { success: false, error: 'Empty order' }
  }
  if (!user) {
    return { success: false, error: 'User required' }
  }
  if (!user.paymentMethod) {
    return { success: false, error: 'No payment method' }
  }
  if (order.total > user.creditLimit) {
    return { success: false, error: 'Credit limit exceeded' }
  }

  // Main logic is now at the top level, easy to read
  const payment = chargePayment(user.paymentMethod, order.total)
  order.status = 'paid'
  return { success: true, transactionId: payment.id }
}
```

**Benefits:**
- Validation logic is clearly separated from business logic
- Maximum nesting depth is 1 instead of 5+
- Easy to add new validations without restructuring

Reference: [Replace Nested Conditional with Guard Clauses](https://refactoring.com/catalog/replaceNestedConditionalWithGuardClauses.html)
