---
title: Apply Open-Closed Principle
impact: MEDIUM-HIGH
impactDescription: enables extension without modifying existing tested code
tags: pattern, ocp, solid, extensibility
---

## Apply Open-Closed Principle

Classes should be open for extension but closed for modification. Design so that new behavior can be added without changing existing code.

**Incorrect (requires modification for new types):**

```typescript
class DiscountCalculator {
  calculate(order: Order): number {
    let discount = 0

    // Adding a new discount type requires modifying this method
    if (order.customer.isPremium) {
      discount += order.total * 0.1
    }

    if (order.items.length > 10) {
      discount += order.total * 0.05
    }

    if (order.coupon) {
      if (order.coupon.type === 'percentage') {
        discount += order.total * (order.coupon.value / 100)
      } else if (order.coupon.type === 'fixed') {
        discount += order.coupon.value
      }
      // New coupon type? Modify this method
    }

    if (isHolidaySeason()) {
      discount += order.total * 0.15
    }

    return Math.min(discount, order.total)
  }
}
```

**Correct (extensible via new classes):**

```typescript
interface DiscountRule {
  calculate(order: Order): number
}

class PremiumCustomerDiscount implements DiscountRule {
  calculate(order: Order): number {
    return order.customer.isPremium ? order.total * 0.1 : 0
  }
}

class BulkOrderDiscount implements DiscountRule {
  calculate(order: Order): number {
    return order.items.length > 10 ? order.total * 0.05 : 0
  }
}

class CouponDiscount implements DiscountRule {
  calculate(order: Order): number {
    if (!order.coupon) return 0
    return order.coupon.type === 'percentage'
      ? order.total * (order.coupon.value / 100)
      : order.coupon.value
  }
}

class DiscountCalculator {
  constructor(private rules: DiscountRule[]) {}

  calculate(order: Order): number {
    const totalDiscount = this.rules.reduce(
      (sum, rule) => sum + rule.calculate(order),
      0
    )
    return Math.min(totalDiscount, order.total)
  }
}

// Adding new discount: create new class, inject it - no modification needed
class HolidayDiscount implements DiscountRule {
  calculate(order: Order): number {
    return isHolidaySeason() ? order.total * 0.15 : 0
  }
}

const calculator = new DiscountCalculator([
  new PremiumCustomerDiscount(),
  new BulkOrderDiscount(),
  new CouponDiscount(),
  new HolidayDiscount()  // Added without modifying DiscountCalculator
])
```

**Benefits:**
- New discount rules added without risk to existing rules
- Each rule can be tested independently
- Rules can be conditionally included at runtime

Reference: [Open-Closed Principle](https://en.wikipedia.org/wiki/Open%E2%80%93closed_principle)
