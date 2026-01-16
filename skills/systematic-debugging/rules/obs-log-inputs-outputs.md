---
title: Log Function Inputs and Outputs
impact: HIGH
impactDescription: Reveals data transformation issues; enables replay debugging
tags: obs, logging, inputs, outputs, data-flow
---

## Log Function Inputs and Outputs

When debugging data issues, log what goes into and comes out of functions. This creates a data flow trace that reveals exactly where values become incorrect.

**Incorrect (logging inside function only):**

```javascript
function transformData(items) {
  console.log("transforming items");  // No actual data
  const result = items.map(item => ({
    id: item.id,
    total: item.price * item.qty,
    name: item.name.toUpperCase()
  }));
  console.log("transform complete");  // Still no data
  return result;
}

// Bug: Totals are wrong
// Logs tell you nothing about actual values
```

**Correct (log inputs and outputs):**

```javascript
function transformData(items) {
  // Log input with identifying info
  console.log("transformData INPUT:", JSON.stringify({
    count: items.length,
    sample: items[0],  // First item as example
    itemIds: items.map(i => i.id)
  }, null, 2));

  const result = items.map(item => ({
    id: item.id,
    total: item.price * item.qty,
    name: item.name.toUpperCase()
  }));

  // Log output with same structure
  console.log("transformData OUTPUT:", JSON.stringify({
    count: result.length,
    sample: result[0],
    totals: result.map(r => ({ id: r.id, total: r.total }))
  }, null, 2));

  return result;
}

// Output:
// transformData INPUT: {
//   "count": 3,
//   "sample": { "id": 1, "price": 10, "qty": "2", "name": "Widget" }
//                                           ^^^ String not number!
// transformData OUTPUT: {
//   "totals": [{ "id": 1, "total": NaN }]  // Reveals the bug
```

**Input/output logging patterns:**

```python
# Decorator pattern for automatic logging
def log_io(func):
    def wrapper(*args, **kwargs):
        logger.debug(f"{func.__name__} called", extra={
            "args": str(args)[:200],  # Truncate large data
            "kwargs": str(kwargs)[:200]
        })
        result = func(*args, **kwargs)
        logger.debug(f"{func.__name__} returned", extra={
            "result_type": type(result).__name__,
            "result_preview": str(result)[:200]
        })
        return result
    return wrapper

@log_io
def calculate_total(items):
    return sum(item.price * item.qty for item in items)
```

**When NOT to use this pattern:**
- Functions called thousands of times (performance impact)
- Functions with huge inputs/outputs (log summaries instead)
- Sensitive data (passwords, PII)

Reference: [Effective Debugging and Logging](https://www.datanovia.com/learn/programming/python/advanced/debugging-and-logging.html)
