---
title: Use Appropriate Log Levels
impact: HIGH
impactDescription: reduces log noise by 90%
tags: log, levels, severity, filtering
---

## Use Appropriate Log Levels

Use log levels consistently to enable filtering. DEBUG for development details, INFO for normal operations, WARN for recoverable issues, ERROR for failures requiring attention.

**Incorrect (everything at same level):**

```python
def process_payment(payment):
    logger.info(f"Starting payment processing")          # Fine
    logger.info(f"Payment amount: {payment.amount}")     # Should be DEBUG
    logger.info(f"Calling payment gateway")              # Should be DEBUG
    logger.info(f"Gateway response: {response}")         # Should be DEBUG
    logger.info(f"Payment failed: {error}")              # Should be ERROR!
    logger.info(f"Retrying payment")                     # Should be WARN
    logger.info(f"Payment completed")                    # Fine

# Production: All logs at INFO, no way to filter
# "Find all payment failures" = search through millions of INFO logs
```

**Correct (appropriate levels):**

```python
def process_payment(payment):
    logger.info("payment_processing_started",
                payment_id=payment.id)

    logger.debug("payment_details",
                 amount=payment.amount,
                 currency=payment.currency)          # Filtered out in prod

    logger.debug("gateway_request_sent",
                 gateway="stripe")                   # Filtered out in prod

    if response.status == "failed":
        logger.error("payment_failed",
                     payment_id=payment.id,
                     error_code=response.error,
                     user_id=payment.user_id)        # Always visible

        logger.warning("payment_retry_scheduled",
                       payment_id=payment.id,
                       retry_count=1)                # Visible, not critical

    logger.info("payment_completed",
                payment_id=payment.id,
                gateway_ref=response.ref)
```

**Log level guidelines:**
| Level | Use For | Production Visibility |
|-------|---------|----------------------|
| DEBUG | Variable values, flow tracing | Off |
| INFO | Business events, milestones | On |
| WARN | Recoverable issues, retries | On |
| ERROR | Failures requiring attention | On + Alert |

Reference: [Medium - Effective Logging Strategies](https://juliofalbo.medium.com/effective-logging-strategies-for-better-observability-and-debugging-4b90decefdf1)
