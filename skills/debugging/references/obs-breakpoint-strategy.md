---
title: Use Breakpoints Strategically
impact: HIGH
impactDescription: 10× faster inspection than print statements; enables state exploration
tags: obs, breakpoints, debugger, inspection, interactive
---

## Use Breakpoints Strategically

Place breakpoints at decision points and state transitions, not randomly. Strategic breakpoints let you inspect program state interactively, enabling deeper exploration than static print statements.

**Incorrect (breakpoints everywhere):**

```python
def process_payment(order, payment_method):
    # Breakpoint here
    total = order.total
    # Breakpoint here
    tax = calculate_tax(total)
    # Breakpoint here
    final = total + tax
    # Breakpoint here
    result = charge_card(payment_method, final)
    # Breakpoint here
    if result.success:
        # Breakpoint here
        update_inventory(order)
        # Breakpoint here
        send_receipt(order)
    # Breakpoint here
    return result

# Developer hits F5/Continue 8 times, loses track of state
```

**Correct (strategic breakpoints):**

```python
def process_payment(order, payment_method):
    total = order.total
    tax = calculate_tax(total)
    final = total + tax

    # BREAKPOINT 1: Before external API call
    # Inspect: final, payment_method, order state
    result = charge_card(payment_method, final)

    # BREAKPOINT 2: After external call, before branching
    # Inspect: result.success, result.error, result.transaction_id
    if result.success:
        update_inventory(order)
        send_receipt(order)

    # BREAKPOINT 3: Before return (conditional)
    # Only hit if debugging return value issues
    return result
```

**Strategic breakpoint locations:**
1. **Before external calls** (APIs, database) - verify inputs
2. **After external calls** - verify responses
3. **At decision points** (if/switch) - understand branching
4. **Loop entry** - verify initial state
5. **After complex calculations** - verify results

**Power features to use:**

```python
# Conditional breakpoint (IDE dependent)
# Break only when: order.total > 1000

# Logpoint (print without stopping)
# Log: f"Processing order {order.id}, total={order.total}"

# Hit count breakpoint
# Break after 10 hits (useful for loops)

# Exception breakpoint
# Break when specific exception is raised
```

**When NOT to use this pattern:**
- Remote debugging where breakpoints cause timeouts
- Multi-threaded race conditions (breakpoints change timing)
- Production environments

Reference: [VS Code Debugging](https://code.visualstudio.com/docs/debugtest/debugging)
