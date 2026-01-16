---
title: Use Watch Expressions to Track State
impact: MEDIUM-HIGH
impactDescription: reduces manual inspection by 10×
tags: debug, watch, expressions, state-tracking
---

## Use Watch Expressions to Track State

Add watch expressions for variables and computed values you want to monitor as you step through code. Watch expressions update automatically at each debugger pause, revealing how state changes over time.

**Incorrect (manually inspecting variables each step):**

```typescript
function processTransaction(account: Account, amount: number) {
  const balance = account.balance
  // Manual inspection: hover over 'balance'
  const fee = calculateFee(amount)
  // Manual inspection: hover over 'fee'
  const newBalance = balance - amount - fee
  // Manual inspection: hover over 'newBalance'
  account.balance = newBalance
  // Manual inspection: hover over 'account.balance'
  // Tedious, error-prone, lose track of values
}
```

**Correct (watch expressions track state automatically):**

```typescript
function processTransaction(account: Account, amount: number) {
  // Watch expressions (added in debugger):
  // 1. account.balance
  // 2. amount
  // 3. account.balance - amount  (computed expression)
  // 4. typeof fee  (check type)

  const balance = account.balance
  // Watch panel shows: balance=1000, amount=100, difference=900

  const fee = calculateFee(amount)
  // Watch panel shows: fee="10"  <- String! Type bug found

  const newBalance = balance - amount - fee
  // Watch panel shows: newBalance=NaN (string concat, not subtraction)

  account.balance = newBalance
}
```

**Useful watch expressions:**
- `variable` - Simple value tracking
- `array.length` - Collection size
- `object.property?.nested` - Nested values with null safety
- `typeof variable` - Type checking
- `JSON.stringify(object)` - Full object inspection
- `condition ? 'yes' : 'no'` - Condition evaluation

Reference: [Meegle - Debugging Best Practices](https://www.meegle.com/en_us/topics/debugging/debugging-best-practices)
