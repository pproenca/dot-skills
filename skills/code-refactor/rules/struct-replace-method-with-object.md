---
title: Replace Method with Method Object
impact: CRITICAL
impactDescription: enables extraction from complex methods with many local variables
tags: struct, method-object, decomposition, local-variables
---

## Replace Method with Method Object

When a long method has many local variables that make extraction difficult, turn the method into its own class. Local variables become instance fields, enabling easy decomposition.

**Incorrect (method with many interdependent locals):**

```typescript
class PriceCalculator {
  calculatePrice(order: Order): PriceBreakdown {
    let basePrice = 0
    let quantity = 0

    for (const item of order.items) {
      basePrice += item.unitPrice * item.quantity
      quantity += item.quantity
    }

    // Volume discount depends on quantity
    let volumeDiscount = 0
    if (quantity > 100) {
      volumeDiscount = basePrice * 0.15
    } else if (quantity > 50) {
      volumeDiscount = basePrice * 0.10
    } else if (quantity > 20) {
      volumeDiscount = basePrice * 0.05
    }

    // Loyalty discount depends on base price after volume
    const afterVolume = basePrice - volumeDiscount
    let loyaltyDiscount = 0
    if (order.customer.loyaltyYears > 5) {
      loyaltyDiscount = afterVolume * 0.10
    } else if (order.customer.loyaltyYears > 2) {
      loyaltyDiscount = afterVolume * 0.05
    }

    // Shipping depends on final price
    const subtotal = afterVolume - loyaltyDiscount
    let shipping = subtotal > 200 ? 0 : 15

    return { basePrice, volumeDiscount, loyaltyDiscount, shipping, total: subtotal + shipping }
  }
}
```

**Correct (extracted to method object):**

```typescript
class PriceCalculator {
  calculatePrice(order: Order): PriceBreakdown {
    return new PriceCalculation(order).compute()
  }
}

class PriceCalculation {
  private basePrice = 0
  private quantity = 0
  private volumeDiscount = 0
  private loyaltyDiscount = 0
  private shipping = 0

  constructor(private order: Order) {}

  compute(): PriceBreakdown {
    this.calculateBasePrice()
    this.calculateVolumeDiscount()
    this.calculateLoyaltyDiscount()
    this.calculateShipping()

    return this.buildResult()
  }

  private calculateBasePrice(): void {
    for (const item of this.order.items) {
      this.basePrice += item.unitPrice * item.quantity
      this.quantity += item.quantity
    }
  }

  private calculateVolumeDiscount(): void {
    if (this.quantity > 100) {
      this.volumeDiscount = this.basePrice * 0.15
    } else if (this.quantity > 50) {
      this.volumeDiscount = this.basePrice * 0.10
    } else if (this.quantity > 20) {
      this.volumeDiscount = this.basePrice * 0.05
    }
  }

  private calculateLoyaltyDiscount(): void {
    const afterVolume = this.basePrice - this.volumeDiscount
    if (this.order.customer.loyaltyYears > 5) {
      this.loyaltyDiscount = afterVolume * 0.10
    } else if (this.order.customer.loyaltyYears > 2) {
      this.loyaltyDiscount = afterVolume * 0.05
    }
  }

  private calculateShipping(): void {
    const subtotal = this.basePrice - this.volumeDiscount - this.loyaltyDiscount
    this.shipping = subtotal > 200 ? 0 : 15
  }

  private buildResult(): PriceBreakdown {
    const subtotal = this.basePrice - this.volumeDiscount - this.loyaltyDiscount
    return {
      basePrice: this.basePrice,
      volumeDiscount: this.volumeDiscount,
      loyaltyDiscount: this.loyaltyDiscount,
      shipping: this.shipping,
      total: subtotal + this.shipping
    }
  }
}
```

**Benefits:**
- Each calculation step can be tested independently
- Easy to add new discount types without modifying existing code
- Local variables become visible state that can be inspected during debugging

Reference: [Replace Method with Method Object](https://refactoring.com/catalog/replaceFunctionWithCommand.html)
