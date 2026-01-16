---
title: Fail Fast with Preconditions
impact: MEDIUM
impactDescription: reduces debugging time by 50-70%
tags: error, fail-fast, preconditions, validation
---

## Fail Fast with Preconditions

Check preconditions at the start of functions and fail immediately if they're violated. Don't let invalid data propagate through the system.

**Incorrect (late validation allows corruption to spread):**

```typescript
function processOrder(order: Order): Receipt {
  // No validation at entry point
  const items = order.items
  let total = 0

  for (const item of items) {
    const product = getProduct(item.productId)  // Might be null
    total += product.price * item.quantity  // Crashes here, far from source
  }

  const tax = total * order.taxRate  // taxRate might be undefined
  const finalTotal = total + tax  // NaN if taxRate was undefined

  // Creates receipt with corrupted data
  return createReceipt(order.customerId, finalTotal)  // customerId might be null
}

// Error surfaces 3 layers deep, hard to trace back
```

**Correct (fail fast at entry point):**

```typescript
function processOrder(order: Order): Receipt {
  // Validate all preconditions immediately
  assertDefined(order, 'Order is required')
  assertDefined(order.customerId, 'Customer ID is required')
  assertNotEmpty(order.items, 'Order must have at least one item')
  assertPositive(order.taxRate, 'Tax rate must be positive')

  for (const item of order.items) {
    assertDefined(item.productId, 'Product ID is required')
    assertPositive(item.quantity, 'Quantity must be positive')
  }

  // Now safe to process - all data is valid
  const total = calculateTotal(order.items)
  const tax = total * order.taxRate
  return createReceipt(order.customerId, total + tax)
}

// Helper functions for common assertions
function assertDefined<T>(value: T | null | undefined, message: string): asserts value is T {
  if (value === null || value === undefined) {
    throw new PreconditionError(message)
  }
}

function assertNotEmpty<T>(array: T[], message: string): void {
  if (array.length === 0) {
    throw new PreconditionError(message)
  }
}

function assertPositive(value: number, message: string): void {
  if (typeof value !== 'number' || value <= 0 || isNaN(value)) {
    throw new PreconditionError(message)
  }
}
```

**Benefits:**
- Errors caught at the source, not deep in the call stack
- Error messages point directly to the problem
- Invalid state never enters the system

Reference: [Fail Fast Principle](https://martinfowler.com/ieeeSoftware/failFast.pdf)
