---
title: Extract Strategy for Algorithm Variants
impact: MEDIUM-HIGH
impactDescription: enables runtime algorithm swapping and isolated testing
tags: pattern, strategy, algorithm, composition
---

## Extract Strategy for Algorithm Variants

When a class supports multiple algorithms for the same operation, extract each algorithm into its own strategy class. This allows runtime switching and independent testing.

**Incorrect (algorithm variants embedded in class):**

```typescript
class PaymentProcessor {
  processPayment(amount: number, method: string, details: PaymentDetails): PaymentResult {
    if (method === 'credit_card') {
      // 20 lines of credit card processing logic
      const encrypted = encryptCardData(details.cardNumber, details.cvv)
      const gateway = connectToStripeGateway()
      const auth = gateway.authorize(encrypted, amount)
      if (!auth.success) {
        return { success: false, error: auth.message }
      }
      const capture = gateway.capture(auth.transactionId)
      return { success: true, transactionId: capture.id }
    } else if (method === 'paypal') {
      // 15 lines of PayPal logic
      const redirect = initiatePayPalFlow(amount, details.returnUrl)
      // ...
    } else if (method === 'crypto') {
      // 25 lines of crypto payment logic
      const wallet = connectToWallet(details.walletAddress)
      // ...
    }
    throw new Error(`Unknown payment method: ${method}`)
  }
}
```

**Correct (strategy pattern):**

```typescript
interface PaymentStrategy {
  processPayment(amount: number, details: PaymentDetails): PaymentResult
}

class CreditCardStrategy implements PaymentStrategy {
  processPayment(amount: number, details: PaymentDetails): PaymentResult {
    const encrypted = encryptCardData(details.cardNumber, details.cvv)
    const gateway = connectToStripeGateway()
    const auth = gateway.authorize(encrypted, amount)
    if (!auth.success) {
      return { success: false, error: auth.message }
    }
    const capture = gateway.capture(auth.transactionId)
    return { success: true, transactionId: capture.id }
  }
}

class PayPalStrategy implements PaymentStrategy {
  processPayment(amount: number, details: PaymentDetails): PaymentResult {
    const redirect = initiatePayPalFlow(amount, details.returnUrl)
    // PayPal-specific logic
    return { success: true, transactionId: redirect.id }
  }
}

class PaymentProcessor {
  constructor(private strategies: Map<string, PaymentStrategy>) {}

  processPayment(amount: number, method: string, details: PaymentDetails): PaymentResult {
    const strategy = this.strategies.get(method)
    if (!strategy) {
      throw new Error(`Unknown payment method: ${method}`)
    }
    return strategy.processPayment(amount, details)
  }
}
```

**Benefits:**
- Each strategy can be unit tested independently
- New payment methods added without modifying PaymentProcessor
- Strategies can be swapped at runtime (A/B testing)

Reference: [Strategy Pattern](https://refactoring.guru/design-patterns/strategy)
