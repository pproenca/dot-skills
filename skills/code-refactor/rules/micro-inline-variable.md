---
title: Inline Trivial Variables
impact: LOW
impactDescription: reduces indirection and visual clutter
tags: micro, inline, variable, simplification
---

## Inline Trivial Variables

When a variable is used only once and its expression is just as clear, inline it. Extra variables add cognitive overhead without adding clarity.

**Incorrect (unnecessary intermediate variables):**

```typescript
function isValidOrder(order: Order): boolean {
  const hasItems = order.items.length > 0
  const hasCustomer = order.customerId !== null
  const isNotCancelled = order.status !== 'cancelled'

  return hasItems && hasCustomer && isNotCancelled
}

function formatPrice(amount: number): string {
  const roundedAmount = Math.round(amount * 100) / 100
  const formattedAmount = roundedAmount.toFixed(2)
  const priceWithSymbol = '$' + formattedAmount

  return priceWithSymbol
}

function getDiscount(customer: Customer): number {
  const isPremium = customer.tier === 'premium'
  const discount = isPremium ? 0.2 : 0

  return discount
}
```

**Correct (inlined trivial expressions):**

```typescript
function isValidOrder(order: Order): boolean {
  return order.items.length > 0 &&
         order.customerId !== null &&
         order.status !== 'cancelled'
}

function formatPrice(amount: number): string {
  return '$' + (Math.round(amount * 100) / 100).toFixed(2)
}

function getDiscount(customer: Customer): number {
  return customer.tier === 'premium' ? 0.2 : 0
}
```

**When NOT to inline:**
- Variable name adds significant clarity to a complex expression
- Variable is used multiple times
- Expression has side effects (should only execute once)
- Debugging benefits from inspecting intermediate values

**Keep the variable when it documents intent:**

```typescript
// Keep - the name adds meaning
function shouldShowWarning(user: User, action: Action): boolean {
  const hasDestructiveIntent = action.type === 'delete' || action.type === 'purge'
  const lacksConfirmation = !action.confirmed
  const isHighValueTarget = user.accountValue > 10000

  return hasDestructiveIntent && lacksConfirmation && isHighValueTarget
}
```

Reference: [Inline Variable](https://refactoring.com/catalog/inlineVariable.html)
