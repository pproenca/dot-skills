---
title: Improve Error Messages When You Debug
impact: LOW-MEDIUM
impactDescription: Reduces future debugging time; helps next developer (including future you)
tags: prev, error-messages, diagnostics, improvement, helping-others
---

## Improve Error Messages When You Debug

When a bug takes a long time to find because error messages were unhelpful, improve those messages as part of your fix. Pay forward the debugging effort to help the next person.

**Incorrect (leaving poor error messages):**

```python
# Original code with unhelpful error
def process_order(order_id):
    order = get_order(order_id)
    if not order:
        raise Exception("Error")  # What error? What order?

# Developer spends 2 hours finding bug
# Fixes the immediate issue
# Leaves the poor error message unchanged
# Next developer will also struggle
```

**Correct (improve messages while fixing):**

```python
# After spending 2 hours debugging, improve the error for next time
def process_order(order_id):
    if not order_id:
        raise ValueError(
            f"order_id is required but got: {order_id!r}. "
            f"Check if the API request includes 'order_id' field."
        )

    order = get_order(order_id)
    if not order:
        raise OrderNotFoundError(
            f"Order {order_id} not found. "
            f"Possible causes: "
            f"1) Order was deleted, 2) Wrong environment, "
            f"3) order_id from different tenant. "
            f"Query: SELECT * FROM orders WHERE id = '{order_id}'"
        )

    if order.status == 'cancelled':
        raise InvalidOrderStateError(
            f"Cannot process cancelled order {order_id}. "
            f"Order was cancelled at {order.cancelled_at} by {order.cancelled_by}. "
            f"Use /api/orders/{order_id}/reinstate to restore if needed."
        )
```

**Good error message components:**
- **What happened**: Clear description of the failure
- **Context**: Relevant data values (IDs, states)
- **Why it might have happened**: Common causes
- **What to do**: Suggested next steps or fixes

**Error message improvements to make:**

| Bad Message | Good Message |
|-------------|--------------|
| "Error" | "Database connection failed: timeout after 30s connecting to db.example.com:5432" |
| "Invalid input" | "Invalid email format: 'user@' - expected format: user@domain.com" |
| "Not found" | "User 'alice' not found in organization 'acme'. Did you mean 'alice.smith'?" |
| "Permission denied" | "Permission denied: user 'bob' lacks 'admin' role required for /api/admin. Contact your org admin." |

**When NOT to use this pattern:**
- Error message is already clear and helpful
- Security-sensitive errors (don't leak implementation details)
- High-frequency errors where message generation is expensive

Reference: [Why Programs Fail - Observing Facts](https://www.whyprogramsfail.com/)
