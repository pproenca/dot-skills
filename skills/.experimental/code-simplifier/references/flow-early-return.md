---
title: Use Early Returns to Reduce Nesting
impact: HIGH
impactDescription: Early returns reduce average nesting depth by 2-3 levels, cutting cognitive load by 40-60% per function
tags: flow, nesting, readability, cognitive-load
---

## Use Early Returns to Reduce Nesting

Deep nesting forces readers to mentally track multiple conditions simultaneously. Early returns eliminate wrapper conditions by handling edge cases immediately and exiting. This creates a linear reading flow where each line is at the same indentation level, dramatically improving comprehension.

**Incorrect (deeply nested logic):**

```typescript
function processOrder(order: Order): Result {
  if (order) {
    if (order.items.length > 0) {
      if (order.customer) {
        if (order.customer.isActive) {
          if (order.paymentMethod) {
            const total = calculateTotal(order.items);
            if (total > 0) {
              const discount = getDiscount(order.customer);
              const finalTotal = total - discount;
              return chargeCustomer(order.customer, finalTotal);
            } else {
              return { error: 'Invalid total' };
            }
          } else {
            return { error: 'No payment method' };
          }
        } else {
          return { error: 'Customer inactive' };
        }
      } else {
        return { error: 'No customer' };
      }
    } else {
      return { error: 'No items' };
    }
  } else {
    return { error: 'No order' };
  }
}
```

**Correct (early returns, flat structure):**

```typescript
function processOrder(order: Order): Result {
  if (!order) {
    return { error: 'No order' };
  }
  if (order.items.length === 0) {
    return { error: 'No items' };
  }
  if (!order.customer) {
    return { error: 'No customer' };
  }
  if (!order.customer.isActive) {
    return { error: 'Customer inactive' };
  }
  if (!order.paymentMethod) {
    return { error: 'No payment method' };
  }

  const total = calculateTotal(order.items);
  if (total <= 0) {
    return { error: 'Invalid total' };
  }

  const discount = getDiscount(order.customer);
  const finalTotal = total - discount;
  return chargeCustomer(order.customer, finalTotal);
}
```

### Benefits

- Reading flow is top-to-bottom without mental stack
- Error conditions are visually grouped at the top
- Happy path is clearly visible at the bottom
- Each condition can be understood in isolation
- Easier to add new validations without restructuring

### When NOT to Apply

- When the nested structure represents meaningful domain hierarchy
- In functional programming contexts where early return breaks composition
- When using exhaustive pattern matching that requires all branches
