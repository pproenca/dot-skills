---
title: Question Your Assumptions
impact: HIGH
impactDescription: Uncovers hidden bugs; 40%+ of debugging time is wasted on false assumptions
tags: rca, assumptions, verification, questioning, bias
---

## Question Your Assumptions

Explicitly list and verify your assumptions about how the code works. Many bugs hide behind incorrect assumptions that we never think to question.

**Incorrect (assuming code works as expected):**

```javascript
// Bug: Totals don't match between pages

function getOrderTotal(orderId) {
  const order = orders.get(orderId);
  return order.total;  // ASSUMPTION: order.total is always current

  // Developer assumes:
  // - orders.get() returns live data (but is it cached?)
  // - order.total is calculated (but is it stale?)
  // - total means the same thing everywhere (but is it pre-tax here?)
  // Spends hours looking at calculation logic when data is just stale
}
```

**Correct (verify assumptions):**

```javascript
// Bug: Totals don't match between pages

function getOrderTotal(orderId) {
  const order = orders.get(orderId);

  // Verify assumptions explicitly:
  console.log("ASSUMPTION CHECK:", {
    // Is orders.get() returning fresh data?
    "order from cache?": orders.isFromCache(orderId),

    // Is order.total calculated or stored?
    "total property type": typeof order.total,
    "has calculated total?": typeof order.calculateTotal === 'function',

    // What exactly is in total?
    "total value": order.total,
    "includes tax?": order.totalIncludesTax,

    // When was this order last updated?
    "last updated": order.updatedAt,
    "current time": new Date()
  });

  return order.total;
}

// Output reveals: order is cached, total is 2 hours stale
// BUG: Cache not invalidated on order updates
```

**Common assumptions to question:**

| Assumption | Reality Check |
|------------|---------------|
| "This function is called" | Add log to verify |
| "This value is always set" | Check for null/undefined |
| "This data is fresh" | Check timestamps, cache status |
| "These mean the same thing" | Compare definitions |
| "This config is correct" | Print actual config values |
| "This library works as documented" | Test in isolation |
| "This branch runs" | Add log at branch entry |
| "The order of execution is X" | Add sequence logs |

**When NOT to use this pattern:**
- Well-tested code with strong guarantees
- When assumptions are verified by type system

Reference: [A Systematic Approach to Debugging](https://ntietz.com/blog/how-i-debug-2023/)
