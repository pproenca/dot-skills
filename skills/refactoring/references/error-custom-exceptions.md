---
title: Create Domain-Specific Exception Types
impact: MEDIUM
impactDescription: enables precise error handling and better error messages
tags: error, custom-exceptions, domain, hierarchy
---

## Create Domain-Specific Exception Types

Generic exceptions force callers to parse error messages. Create typed exceptions that carry structured information about what went wrong.

**Incorrect (generic exceptions with string messages):**

```typescript
function transferMoney(from: Account, to: Account, amount: number): void {
  if (amount <= 0) {
    throw new Error('Invalid amount')
  }
  if (from.balance < amount) {
    throw new Error('Insufficient funds')  // No details
  }
  if (from.id === to.id) {
    throw new Error('Cannot transfer to same account')
  }
  if (from.status === 'frozen') {
    throw new Error('Account is frozen')  // Which account?
  }

  // Process transfer...
}

// Caller has to parse strings to determine error type
try {
  transferMoney(source, dest, 100)
} catch (error) {
  if (error.message.includes('Insufficient')) {  // Fragile string matching
    // Handle insufficient funds
  } else if (error.message.includes('frozen')) {
    // Handle frozen account
  }
}
```

**Correct (domain-specific exception hierarchy):**

```typescript
abstract class TransferError extends Error {
  abstract readonly code: string
}

class InsufficientFundsError extends TransferError {
  readonly code = 'INSUFFICIENT_FUNDS'

  constructor(
    public readonly accountId: string,
    public readonly available: number,
    public readonly requested: number
  ) {
    super(`Account ${accountId} has ${available}, but ${requested} was requested`)
  }

  get shortfall(): number {
    return this.requested - this.available
  }
}

class AccountFrozenError extends TransferError {
  readonly code = 'ACCOUNT_FROZEN'

  constructor(
    public readonly accountId: string,
    public readonly reason: string
  ) {
    super(`Account ${accountId} is frozen: ${reason}`)
  }
}

class SameAccountError extends TransferError {
  readonly code = 'SAME_ACCOUNT'

  constructor(public readonly accountId: string) {
    super(`Cannot transfer from account ${accountId} to itself`)
  }
}

function transferMoney(from: Account, to: Account, amount: number): void {
  if (from.balance < amount) {
    throw new InsufficientFundsError(from.id, from.balance, amount)
  }
  if (from.id === to.id) {
    throw new SameAccountError(from.id)
  }
  if (from.status === 'frozen') {
    throw new AccountFrozenError(from.id, from.freezeReason)
  }
  // Process transfer...
}

// Caller uses type-safe handling
try {
  transferMoney(source, dest, 100)
} catch (error) {
  if (error instanceof InsufficientFundsError) {
    showAddFundsPrompt(error.shortfall)  // Access structured data
  } else if (error instanceof AccountFrozenError) {
    showContactSupportMessage(error.accountId, error.reason)
  }
}
```

**Benefits:**
- Type-safe error handling with instanceof
- Structured data available without parsing
- Derived properties (shortfall) on exceptions

Reference: [Clean Code - Error Handling](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
