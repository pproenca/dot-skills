---
title: Master Step Over, Into, and Out
impact: MEDIUM-HIGH
impactDescription: 3-5× faster stepping through code
tags: debug, stepping, navigation, debugger
---

## Master Step Over, Into, and Out

Use step-over to skip trusted functions, step-into to examine suspect functions, and step-out to exit when you've seen enough. Efficient stepping avoids wasting time in irrelevant code.

**Incorrect (stepping into everything):**

```python
def process_order(order):
    validated = validate_order(order)      # Step Into -> 50 lines
    total = calculate_total(order.items)   # Step Into -> 30 lines
    tax = calculate_tax(total)             # Step Into -> 20 lines
    # Bug is in apply_discount, but already spent time in 100 lines
    discounted = apply_discount(total, order.coupon)  # Bug here
    return save_order(order, discounted)

# Inefficient: Stepped through 100 lines of working code
```

**Correct (targeted stepping):**

```python
def process_order(order):
    validated = validate_order(order)      # Step Over (trusted)
    total = calculate_total(order.items)   # Step Over (trusted)
    tax = calculate_tax(total)             # Step Over (trusted)

    # HYPOTHESIS: Bug is in discount calculation
    discounted = apply_discount(total, order.coupon)  # Step Into
    # Inside apply_discount:
    #   discount_rate = get_rate(coupon)  # Step Into (suspect)
    #     # Found: returns None for expired coupons
    #     # Step Out back to apply_discount
    #   return total * (1 - discount_rate)  # total * (1 - None) = NaN

    return save_order(order, discounted)   # Never reached
```

**Stepping strategy:**
| Action | Shortcut | Use When |
|--------|----------|----------|
| Step Over | F10 | Function is trusted, skip internals |
| Step Into | F11 | Function is suspect, examine internals |
| Step Out | Shift+F11 | Seen enough, return to caller |
| Continue | F5 | Run to next breakpoint |

Reference: [GUVI - Debugging in Software Development](https://www.guvi.in/blog/debugging-in-software-development/)
