---
title: Keep Functions Under 20 Lines
impact: CRITICAL
impactDescription: reduces cognitive load and bug density by 30-50%
tags: struct, function-length, readability, complexity
---

## Keep Functions Under 20 Lines

Functions longer than 20 lines are harder to understand, test, and maintain. Research shows bug density increases with function length.

**Incorrect (long function requiring scrolling):**

```typescript
function processPayment(order: Order, paymentMethod: PaymentMethod): PaymentResult {
  // Validate order
  if (!order.items.length) {
    return { success: false, error: 'Empty order' }
  }

  // Calculate amount
  let amount = 0
  for (const item of order.items) {
    amount += item.price * item.quantity
  }

  // Apply discounts
  if (order.couponCode) {
    const coupon = lookupCoupon(order.couponCode)
    if (coupon && coupon.expiresAt > new Date()) {
      if (coupon.type === 'percentage') {
        amount = amount * (1 - coupon.value / 100)
      } else {
        amount = amount - coupon.value
      }
    }
  }

  // Add tax
  const taxRate = getTaxRate(order.shippingAddress.state)
  amount = amount * (1 + taxRate)

  // Process payment
  let paymentResult
  if (paymentMethod.type === 'credit_card') {
    paymentResult = chargeCreditCard(paymentMethod.cardNumber, amount)
  } else if (paymentMethod.type === 'paypal') {
    paymentResult = chargePayPal(paymentMethod.email, amount)
  } else {
    return { success: false, error: 'Unknown payment method' }
  }

  // Handle result
  if (paymentResult.success) {
    updateOrderStatus(order.id, 'paid')
    sendConfirmationEmail(order.customer.email, order.id)
    return { success: true, transactionId: paymentResult.transactionId }
  } else {
    logPaymentFailure(order.id, paymentResult.error)
    return { success: false, error: paymentResult.error }
  }
}
```

**Correct (composed of focused functions):**

```typescript
function processPayment(order: Order, paymentMethod: PaymentMethod): PaymentResult {
  const validationError = validateOrder(order)
  if (validationError) {
    return { success: false, error: validationError }
  }

  const amount = calculateFinalAmount(order)
  const paymentResult = executePayment(paymentMethod, amount)

  return handlePaymentResult(order, paymentResult)
}

function calculateFinalAmount(order: Order): number {
  const subtotal = calculateSubtotal(order.items)
  const discounted = applyDiscounts(subtotal, order.couponCode)
  return applyTax(discounted, order.shippingAddress.state)
}

function handlePaymentResult(order: Order, result: PaymentResult): PaymentResult {
  if (result.success) {
    updateOrderStatus(order.id, 'paid')
    sendConfirmationEmail(order.customer.email, order.id)
  } else {
    logPaymentFailure(order.id, result.error)
  }
  return result
}
```

**When longer functions are acceptable:**
- Complex algorithms that lose clarity when split
- State machines with necessary sequential steps
- Generated code or configuration

Reference: [Clean Code by Robert C. Martin](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
