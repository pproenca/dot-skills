---
title: Model Domain Errors as Discriminated Unions
impact: MEDIUM
impactDescription: enables precise error handling with full type safety
tags: error, discriminated-unions, domain-errors, type-safety
---

## Model Domain Errors as Discriminated Unions

String-based error codes and generic `Error` subclasses lose type information about error-specific data. Discriminated unions encode both the error kind and its associated data, enabling precise handling.

**Incorrect (string codes, loose error data):**

```typescript
class AppError extends Error {
  constructor(
    public code: string,
    message: string,
    public details?: Record<string, unknown>
  ) {
    super(message)
  }
}

function handlePaymentError(error: AppError) {
  if (error.code === "insufficient_funds") {
    const shortfall = error.details?.shortfall as number // Unsafe cast
  }
}
```

**Correct (discriminated union, typed error data):**

```typescript
type PaymentError =
  | { type: "insufficient_funds"; shortfall: number; currency: string }
  | { type: "card_declined"; reason: string; retryable: boolean }
  | { type: "fraud_detected"; transactionId: string }

function handlePaymentError(error: PaymentError) {
  if (error.type === "insufficient_funds") {
    showShortfall(error.shortfall, error.currency) // Fully typed
  }
}
```
