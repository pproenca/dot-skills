---
title: Use Logpoints Instead of Modifying Code
impact: MEDIUM-HIGH
impactDescription: 100% clean commits; zero risk of shipping debug statements to production
tags: tool, logpoints, tracepoints, debugger, non-invasive
---

## Use Logpoints Instead of Modifying Code

Modern debuggers support logpoints (tracepoints) that print messages without modifying source code. This eliminates the risk of committing debug code and doesn't require recompilation.

**Incorrect (adding print statements):**

```python
def process_order(order):
    print(f"DEBUG: order = {order}")  # Added manually
    total = calculate_total(order)
    print(f"DEBUG: total = {total}")  # Added manually
    discount = apply_discount(total, order.user)
    print(f"DEBUG: discount = {discount}")  # Added manually
    return finalize(order, discount)

# Risks:
# - Might commit debug prints to production
# - Have to rebuild/restart after changes
# - Pollutes version control history
# - Easy to forget to remove
```

**Correct (logpoints via debugger):**

```python
def process_order(order):
    # LOGPOINT: "order = {order}"  (set in IDE, not in code)
    total = calculate_total(order)
    # LOGPOINT: "total = {total}"  (set in IDE, not in code)
    discount = apply_discount(total, order.user)
    # LOGPOINT: "discount = {discount}"  (set in IDE, not in code)
    return finalize(order, discount)

# Benefits:
# - No code changes
# - No rebuild needed
# - Nothing to commit/forget
# - Easy to add/remove
```

**Setting logpoints by IDE:**

```text
VS Code:
1. Right-click line → "Add Logpoint"
2. Enter message: "total = {total}, user = {order.user.name}"
3. Logpoint appears as diamond-shaped marker

PyCharm:
1. Click breakpoint → Properties
2. Check "Log message to console"
3. Uncheck "Suspend execution"

Chrome DevTools:
1. Right-click line → "Add logpoint"
2. Enter expression to log
```

**Logpoint expression patterns:**

```javascript
// Simple value logging
"Processing order: {order.id}"

// Multiple values
"User {user.id} balance: {balance}, status: {status}"

// Computed expressions
"Items count: {items.length}, first: {items[0]?.name}"

// Conditional messages (VS Code)
"Large order!" // With condition: order.total > 1000
```

**When NOT to use this pattern:**
- Need permanent logging for production monitoring
- Debugging without IDE (remote, production)

Reference: [VS Code Logpoints](https://code.visualstudio.com/docs/debugtest/debugging#_logpoints)
