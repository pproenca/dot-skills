---
title: Use Structured Logging for Debugging
impact: HIGH
impactDescription: enables filtering and querying at scale
tags: log, structured, json, observability
---

## Use Structured Logging for Debugging

Use structured logging (JSON format with consistent fields) instead of plain text. Structured logs are machine-parseable, enabling filtering, aggregation, and correlation that plain text cannot support.

**Incorrect (plain text logging):**

```python
# Plain text logs are hard to parse and query

def process_order(order_id, user_id):
    print(f"Processing order {order_id} for user {user_id}")
    # ...
    print(f"Order {order_id} total: ${total}")
    # ...
    print(f"ERROR: Payment failed for order {order_id}")

# Log output:
# Processing order 12345 for user 789
# Order 12345 total: $150.00
# ERROR: Payment failed for order 12345

# Query "all failed payments for user 789"? Impossible without regex
```

**Correct (structured logging):**

```python
import structlog

logger = structlog.get_logger()

def process_order(order_id, user_id):
    logger.info("order_processing_started",
                order_id=order_id,
                user_id=user_id)
    # ...
    logger.info("order_total_calculated",
                order_id=order_id,
                total=total,
                currency="USD")
    # ...
    logger.error("payment_failed",
                 order_id=order_id,
                 user_id=user_id,
                 error_code="CARD_DECLINED")

# Log output (JSON):
# {"event": "payment_failed", "order_id": 12345, "user_id": 789, "error_code": "CARD_DECLINED"}

# Query in log aggregator:
# event:payment_failed AND user_id:789
# Instantly find all payment failures for user 789
```

**Benefits:**
- Filter by any field: `user_id:789 AND level:error`
- Aggregate: "Count of payment failures per error code"
- Alert: Notify when error rate exceeds threshold

Reference: [IBM - Three Pillars of Observability](https://www.ibm.com/think/insights/observability-pillars)
