---
title: Use Conditional Breakpoints for Specific Cases
impact: MEDIUM-HIGH
impactDescription: avoids N iterations of manual stepping
tags: debug, conditional, breakpoints, filtering
---

## Use Conditional Breakpoints for Specific Cases

When a bug occurs only for specific inputs or iterations, use conditional breakpoints to pause execution only when those conditions are met. This avoids stepping through thousands of irrelevant iterations.

**Incorrect (regular breakpoint in loop):**

```javascript
function processOrders(orders) {
  for (const order of orders) {
    // Bug: Order #4582 has wrong total
    calculateTotal(order)  // Regular breakpoint
    // Must click "Continue" 4581 times to reach the bug
  }
}
```

**Correct (conditional breakpoint):**

```javascript
function processOrders(orders) {
  for (const order of orders) {
    // Conditional breakpoint: order.id === 4582
    calculateTotal(order)  // Stops only for order #4582
    // Immediately examine the problematic order
  }
}

// In debugger:
// Breakpoint condition: order.id === 4582
// Or: order.total > 10000  (find all large orders)
// Or: order.items.length === 0  (find empty orders)
```

**Conditional breakpoint use cases:**
- Loop iterations: `i === 999` or `i % 1000 === 0`
- Specific users: `user.id === "alice"` or `user.role === "admin"`
- Error conditions: `response.status >= 400`
- Edge cases: `items.length === 0` or `value === null`

**Alternative: Logpoints**
```javascript
// Instead of breaking, log values without pausing
// Logpoint expression: `Order ${order.id}: total=${order.total}`
// Output: Order 4582: total=NaN  <- Found the bug
```

Reference: [TechNetExperts - 25 Debugging Techniques](https://www.technetexperts.com/debugging-techniques-every-developer-should-know/)
