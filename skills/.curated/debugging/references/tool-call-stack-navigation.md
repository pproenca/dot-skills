---
title: Navigate the Call Stack
impact: MEDIUM-HIGH
impactDescription: 3× faster context discovery; reveals parameter values at each call level
tags: tool, call-stack, debugger, context, navigation
---

## Navigate the Call Stack

Use the call stack panel to move up and down the execution chain. Each frame shows local variables at that point, helping you understand how you reached the current state.

**Incorrect (only looking at current frame):**

```python
# Debugger stopped in deep function
def calculate_tax(amount, rate):
    # Breakpoint here
    return amount * rate  # rate is 0.25, but should be 0.08?

# Developer wonders: "Where did 0.25 come from?"
# Only looks at this function, can't see caller context
```

**Correct (navigate call stack):**

```python
# Call Stack shows:
#   calculate_tax        ← Current frame (bottom)
#   apply_pricing
#   process_line_item
#   process_order
#   handle_request       ← Entry point (top)

# Click on apply_pricing frame to see:
def apply_pricing(item, region):
    rate = get_tax_rate(region)  # rate = 0.25 for "EU" region
    return calculate_tax(item.price, rate)

# Click on process_line_item to see:
def process_line_item(item, order):
    region = order.shipping_region  # region = "EU" (wrong!)
    return apply_pricing(item, region)

# Found it! shipping_region should be billing_region for tax
```

**Call stack navigation techniques:**

```text
┌─────────────────────────────────────────────┐
│ Call Stack                                  │
├─────────────────────────────────────────────┤
│ ► calculate_tax (current)     ← Click here  │
│   apply_pricing               ← Or here     │
│   process_line_item           ← Or here     │
│   process_order                             │
│   handle_request                            │
└─────────────────────────────────────────────┘

Clicking a frame shows:
- Local variables at that point
- Line where next function was called
- Parameter values passed to called function
```

**Questions answered by call stack:**
- How did execution reach this point?
- What parameters were passed at each level?
- What were local variables in parent functions?
- Where should I set breakpoints to catch this earlier?

**When NOT to use this pattern:**
- Recursion with 1000+ frames (hard to navigate)
- Async callbacks (stack may not show full context)

Reference: [VS Code Call Stack](https://code.visualstudio.com/docs/debugtest/debugging#_call-stack)
