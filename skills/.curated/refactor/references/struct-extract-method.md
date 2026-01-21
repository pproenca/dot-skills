---
title: Extract Method for Long Functions
impact: CRITICAL
impactDescription: reduces function complexity by 50-80%
tags: struct, extract-method, decomposition, readability
---

## Extract Method for Long Functions

Long functions are the most common source of code complexity. Extract cohesive blocks of code into well-named methods to improve readability and enable reuse.

**Incorrect (monolithic function with multiple responsibilities):**

```typescript
function processOrder(order: Order): ProcessedOrder {
  // Validate order
  if (!order.items || order.items.length === 0) {
    throw new Error('Order must have items')
  }
  if (!order.customer.email) {
    throw new Error('Customer email required')
  }

  // Calculate totals
  let subtotal = 0
  for (const item of order.items) {
    subtotal += item.price * item.quantity
  }
  const tax = subtotal * 0.1
  const shipping = subtotal > 100 ? 0 : 10
  const total = subtotal + tax + shipping

  // Format for display
  const formattedItems = order.items.map(item => ({
    name: item.name,
    display: `${item.name} x${item.quantity} - $${(item.price * item.quantity).toFixed(2)}`
  }))

  return { ...order, subtotal, tax, shipping, total, formattedItems }
}
```

**Correct (decomposed into focused methods):**

```typescript
function processOrder(order: Order): ProcessedOrder {
  validateOrder(order)
  const totals = calculateTotals(order.items)
  const formattedItems = formatOrderItems(order.items)

  return { ...order, ...totals, formattedItems }
}

function validateOrder(order: Order): void {
  if (!order.items || order.items.length === 0) {
    throw new Error('Order must have items')
  }
  if (!order.customer.email) {
    throw new Error('Customer email required')
  }
}

function calculateTotals(items: OrderItem[]): OrderTotals {
  const subtotal = items.reduce((sum, item) => sum + item.price * item.quantity, 0)
  const tax = subtotal * 0.1
  const shipping = subtotal > 100 ? 0 : 10
  return { subtotal, tax, shipping, total: subtotal + tax + shipping }
}

function formatOrderItems(items: OrderItem[]): FormattedItem[] {
  return items.map(item => ({
    name: item.name,
    display: `${item.name} x${item.quantity} - $${(item.price * item.quantity).toFixed(2)}`
  }))
}
```

**When to extract:**
- Code block has a clear single purpose
- Block is reusable in other contexts
- Block requires its own documentation/testing

Reference: [Extract Function](https://refactoring.com/catalog/extractFunction.html)
