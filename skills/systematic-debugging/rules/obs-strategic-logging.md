---
title: Use Strategic Logging Over Random Print Statements
impact: HIGH
impactDescription: 5× faster bug localization; structured logs enable automated analysis
tags: obs, logging, structured, levels, tracing
---

## Use Strategic Logging Over Random Print Statements

Replace scattered print statements with structured, leveled logging at strategic points. Good logging provides context, can be filtered, persists for analysis, and doesn't require removal before commit.

**Incorrect (random print statements):**

```python
def process_order(order):
    print("here1")  # Where? What?
    print(order)    # Raw dump, hard to parse
    user = get_user(order.user_id)
    print("got user")
    print(user)
    total = calculate_total(order)
    print(f"total is {total}")  # No context
    if total > 1000:
        print("big order!")
        discount = apply_discount(total)
        print(discount)  # Is this the discount or discounted total?
    result = save_order(order)
    print("done")
    return result

# Output:
# here1
# <Order object at 0x...>
# got user
# <User object at 0x...>
# total is 1250
# big order!
# 125
# done
# Which is which? Hard to read, no timestamp, can't filter
```

**Correct (strategic structured logging):**

```python
import logging

logger = logging.getLogger(__name__)

def process_order(order):
    logger.info("Processing order", extra={
        "order_id": order.id,
        "user_id": order.user_id,
        "item_count": len(order.items)
    })

    user = get_user(order.user_id)
    logger.debug("User retrieved", extra={
        "user_id": user.id,
        "member_level": user.member_level
    })

    total = calculate_total(order)
    logger.debug("Total calculated", extra={
        "order_id": order.id,
        "total": total,
        "currency": "USD"
    })

    if total > 1000:
        logger.info("Large order discount applied", extra={
            "order_id": order.id,
            "original_total": total,
            "discount_percent": 10
        })
        total = apply_discount(total)

    result = save_order(order)
    logger.info("Order processed successfully", extra={
        "order_id": order.id,
        "final_total": total
    })
    return result

# Output (JSON format, filterable, parseable):
# {"level": "INFO", "msg": "Processing order", "order_id": 123, ...}
# {"level": "DEBUG", "msg": "User retrieved", "user_id": 456, ...}
```

**Strategic logging placement:**
- Function entry/exit (INFO)
- Major decision points (DEBUG)
- External service calls (INFO with timing)
- Error conditions (ERROR with full context)
- State changes (DEBUG)

**When NOT to use this pattern:**
- Quick one-off investigation (print is fine)
- Performance-critical hot paths (logging has overhead)

Reference: [Advanced Debug Logging Techniques](https://www.infoworld.com/article/4060419/advanced-debug-logging-techniques-a-technical-guide.html)
