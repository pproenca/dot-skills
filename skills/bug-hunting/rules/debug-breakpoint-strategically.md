---
title: Place Breakpoints Strategically
impact: MEDIUM-HIGH
impactDescription: 2-5× faster bug localization
tags: debug, breakpoints, inspection, debugger
---

## Place Breakpoints Strategically

Place breakpoints at decision points and state transitions, not at every line. A breakpoint should answer a specific question about program state at a critical moment.

**Incorrect (breakpoint on every line):**

```python
def calculate_discount(user, cart):
    breakpoint()  # Stop here
    total = cart.subtotal
    breakpoint()  # Stop here
    discount_rate = get_discount_rate(user)
    breakpoint()  # Stop here
    discount = total * discount_rate
    breakpoint()  # Stop here
    final = total - discount
    breakpoint()  # Stop here
    return final

# 5 pauses to step through, tedious and unfocused
```

**Correct (breakpoint at key decision point):**

```python
def calculate_discount(user, cart):
    total = cart.subtotal
    discount_rate = get_discount_rate(user)

    # HYPOTHESIS: discount_rate is wrong for premium users
    # Place ONE breakpoint where discount_rate is used
    discount = total * discount_rate  # Breakpoint here
    # Inspect: discount_rate, user.tier, expected vs actual

    final = total - discount
    return final

# One pause, examine discount_rate: 0.1 (expected 0.2 for premium)
# Root cause found: get_discount_rate() ignores user tier
```

**Strategic breakpoint locations:**
- Before a condition that might evaluate incorrectly
- At the assignment of a variable you suspect is wrong
- At function entry when you suspect wrong parameters
- Just before the line that throws an exception

Reference: [Graphite - Debugging Best Practices Guide](https://graphite.com/guides/debugging-best-practices-guide)
