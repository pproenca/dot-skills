---
title: Plan Error Handling and Recovery
impact: MEDIUM
impactDescription: reduces production incidents by 50%
tags: tech, errors, recovery, resilience
---

## Plan Error Handling and Recovery

Specify how the feature handles failures before implementation. Undefined error handling leads to poor user experience, silent failures, and difficult debugging. Every external call can fail.

**Incorrect (happy path only):**

```markdown
## Feature: Payment Processing

1. User enters card details
2. System charges card via Stripe
3. System creates order
4. User sees confirmation

// What happens when:
// - Stripe is down?
// - Card is declined?
// - Order creation fails after charge?
// - Network timeout mid-transaction?
// Result: Undefined behavior, money lost, support tickets
```

**Correct (explicit error handling specification):**

```markdown
## Feature: Payment Processing - Error Handling

### Failure Modes and Responses

| Failure | Detection | User Experience | System Response |
|---------|-----------|-----------------|-----------------|
| Card declined | Stripe error code | "Card declined. Try another." | Log, no retry |
| Insufficient funds | Stripe error code | "Insufficient funds." | Log, no retry |
| Stripe timeout | 30s timeout | "Processing delayed, check email" | Queue retry |
| Stripe down | 503 response | "Payments temporarily unavailable" | Alert ops, show ETA |
| Network error | Connection refused | "Connection error, retrying..." | Auto-retry 3x |
| Order creation fails | DB error after charge | Silent to user | Refund + alert |

### Transaction Flow with Error Handling

```text
User submits payment
        │
        ▼
┌───────────────────┐
│ Validate input    │──Invalid──▶ Show validation errors
└───────┬───────────┘
        │ Valid
        ▼
┌───────────────────┐
│ Create pending    │──Fail──▶ "Try again later" + Log
│ payment record    │
└───────┬───────────┘
        │ Success
        ▼
┌───────────────────┐
│ Charge via Stripe │──Declined──▶ Show decline reason
└───────┬───────────┘
        │ Success      │
        │              └──Timeout──▶ Queue async check
        ▼
┌───────────────────┐
│ Update payment    │──Fail──▶ Retry 3x, then manual review
│ record: success   │
└───────┬───────────┘
        │ Success
        ▼
┌───────────────────┐
│ Create order      │──Fail──▶ Queue refund + alert
└───────┬───────────┘
        │ Success
        ▼
┌───────────────────┐
│ Send confirmation │──Fail──▶ Queue retry, log warning
└───────┬───────────┘
        │
        ▼
    Show success
```

### Retry Strategy

```yaml
payment_charge:
  max_retries: 0  # Never auto-retry charges
  reason: "Duplicate charges are worse than failed payments"

payment_status_check:
  max_retries: 5
  initial_delay: 1s
  backoff: exponential
  max_delay: 30s
  reason: "Stripe may be slow but will eventually respond"

order_creation:
  max_retries: 3
  initial_delay: 100ms
  backoff: linear
  on_final_failure: queue_refund
  reason: "DB failures are usually transient"

confirmation_email:
  max_retries: 10
  initial_delay: 1s
  backoff: exponential
  max_delay: 1h
  on_final_failure: log_and_continue
  reason: "Email can be delayed, not critical path"
```

### Compensation and Recovery

**Scenario: Order creation fails after successful charge**

```javascript
async function handleOrderCreationFailure(paymentId, error) {
  // 1. Log the failure with full context
  logger.error('Order creation failed after payment', {
    payment_id: paymentId,
    error: error.message,
    stack: error.stack
  });

  // 2. Mark payment for refund
  await PaymentRecord.update(paymentId, {
    status: 'refund_pending',
    failure_reason: error.message
  });

  // 3. Queue refund job (idempotent)
  await RefundQueue.add({
    payment_id: paymentId,
    reason: 'order_creation_failed',
    idempotency_key: `refund-${paymentId}`
  });

  // 4. Alert operations
  await AlertService.notify('payment-ops', {
    severity: 'high',
    message: `Payment ${paymentId} requires refund - order creation failed`
  });
}
```

### Error Response Standards

**User-facing errors:**
```json
{
  "error": {
    "type": "payment_failed",
    "message": "Your card was declined. Please try a different payment method.",
    "code": "card_declined",
    "recoverable": true,
    "suggested_action": "try_different_card"
  }
}
```

**Internal errors (never expose to users):**
- Database connection strings
- Stack traces
- Internal service names
- Raw exception messages
```

**Error handling checklist:**
- All failure modes identified
- User-facing messages defined
- Retry strategies documented
- Compensation/rollback procedures
- Alerting thresholds set

Reference: [Microsoft Cloud Design Patterns - Retry](https://docs.microsoft.com/en-us/azure/architecture/patterns/retry)
