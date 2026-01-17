---
title: Avoid Quick Patches Without Understanding
impact: MEDIUM
impactDescription: Prevents technical debt and recurring bugs; quick fixes often mask real problems
tags: anti, quick-patch, band-aid, technical-debt, anti-pattern
---

## Avoid Quick Patches Without Understanding

Don't apply quick fixes that mask symptoms without understanding the root cause. These create technical debt, hide real problems, and often lead to worse failures later.

**Incorrect (quick patch):**

```python
# Bug: Occasional NullPointerException in process_order

def process_order(order):
    # Quick patch: Just check for None everywhere
    if order is None:
        return None
    if order.user is None:
        return None
    if order.items is None:
        return None

    total = sum(item.price for item in order.items if item is not None)
    if total is None:  # Can't even be None but added anyway
        return None

    return charge_user(order.user, total)

# Symptoms hidden, but:
# - WHY was order None? Still happening somewhere
# - WHY was order.user None? Data corruption? Race condition?
# - These None returns silently fail, no alerts
# - Real bug continues causing data inconsistencies
```

**Correct (understand then fix):**

```python
# Bug: Occasional NullPointerException in process_order

# Step 1: Investigate why order was None
# Added logging: "order is None when called from webhook handler"
# Found: Webhook sends order_id, not order object

# Step 2: Fix at the source
def handle_webhook(data):
    order_id = data.get('order_id')
    if not order_id:
        logger.error("Webhook missing order_id", extra={"data": data})
        raise ValueError("order_id required")

    order = Order.query.get(order_id)
    if not order:
        logger.error(f"Order not found: {order_id}")
        raise ValueError(f"Order {order_id} not found")

    return process_order(order)  # Now guaranteed to have valid order

def process_order(order):
    # No defensive checks needed - contract enforced by caller
    total = sum(item.price for item in order.items)
    return charge_user(order.user, total)
```

**Quick patch red flags:**
- Adding try/except that catches and ignores all exceptions
- Adding null checks everywhere without investigating why nulls occur
- Adding retries without understanding what fails
- Suppressing warning/error logs instead of fixing cause

**When quick patches are acceptable:**
- Critical production issue (patch now, investigate later)
- Third-party bug you can't fix (document and work around)
- Truly defensive code at system boundaries

**Always follow up:**
- Create ticket to investigate root cause
- Schedule time to properly fix after stabilization
- Add monitoring to catch if symptom returns

Reference: [Root Cause Analysis](https://www.techtarget.com/searchsoftwarequality/tip/How-to-handle-root-cause-analysis-of-software-defects)
