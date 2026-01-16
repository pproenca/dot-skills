---
title: Use Exceptions Instead of Error Codes
impact: MEDIUM
impactDescription: separates error handling from happy path and prevents ignored errors
tags: error, exceptions, error-codes, control-flow
---

## Use Exceptions Instead of Error Codes

Error codes mix error handling with normal flow and can be silently ignored. Exceptions clearly separate the error path and force handling.

**Incorrect (error codes mixed with return value):**

```typescript
interface Result<T> {
  success: boolean
  data?: T
  errorCode?: number
  errorMessage?: string
}

function processPayment(amount: number): Result<Payment> {
  if (amount <= 0) {
    return { success: false, errorCode: 1001, errorMessage: 'Invalid amount' }
  }

  const balance = getBalance()
  if (balance < amount) {
    return { success: false, errorCode: 1002, errorMessage: 'Insufficient funds' }
  }

  const payment = createPayment(amount)
  return { success: true, data: payment }
}

// Caller can easily forget to check error
function checkout(cart: Cart): void {
  const result = processPayment(cart.total)
  // Oops, forgot to check result.success
  sendConfirmation(result.data!)  // Crashes if payment failed
}
```

**Correct (exceptions for errors):**

```typescript
class PaymentError extends Error {
  constructor(message: string, public readonly code: string) {
    super(message)
    this.name = 'PaymentError'
  }
}

class InsufficientFundsError extends PaymentError {
  constructor(available: number, required: number) {
    super(`Insufficient funds: have ${available}, need ${required}`, 'INSUFFICIENT_FUNDS')
  }
}

class InvalidAmountError extends PaymentError {
  constructor(amount: number) {
    super(`Invalid amount: ${amount}`, 'INVALID_AMOUNT')
  }
}

function processPayment(amount: number): Payment {
  if (amount <= 0) {
    throw new InvalidAmountError(amount)
  }

  const balance = getBalance()
  if (balance < amount) {
    throw new InsufficientFundsError(balance, amount)
  }

  return createPayment(amount)
}

// Caller must handle the exception or let it propagate
function checkout(cart: Cart): void {
  try {
    const payment = processPayment(cart.total)
    sendConfirmation(payment)  // Only runs if payment succeeded
  } catch (error) {
    if (error instanceof InsufficientFundsError) {
      showFundsNeededMessage(error.message)
    } else {
      throw error  // Rethrow unexpected errors
    }
  }
}
```

**When error codes are appropriate:**
- Performance-critical code where exceptions are too expensive
- Interoperating with languages/systems that use error codes
- Expected failure cases that aren't exceptional (e.g., user input validation)

Reference: [Clean Code - Error Handling](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
