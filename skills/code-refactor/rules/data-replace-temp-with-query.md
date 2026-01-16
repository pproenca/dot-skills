---
title: Replace Temp with Query
impact: MEDIUM
impactDescription: enables reuse and makes intent explicit
tags: data, temp-variable, query-method, extract
---

## Replace Temp with Query

Replace temporary variables with query methods when the value is used multiple times or represents a meaningful concept. This makes the code more self-documenting.

**Incorrect (temporary variable obscures intent):**

```typescript
class Order {
  getPrice(): number {
    const basePrice = this.quantity * this.itemPrice
    let discountFactor: number

    if (basePrice > 1000) {
      discountFactor = 0.95
    } else {
      discountFactor = 0.98
    }

    return basePrice * discountFactor
  }
}

// basePrice concept hidden inside method
// discountFactor logic cannot be reused
```

**Correct (extracted to query methods):**

```typescript
class Order {
  getPrice(): number {
    return this.basePrice * this.discountFactor
  }

  get basePrice(): number {
    return this.quantity * this.itemPrice
  }

  get discountFactor(): number {
    return this.basePrice > 1000 ? 0.95 : 0.98
  }
}

// Now these can be used elsewhere
class OrderPrinter {
  printReceipt(order: Order): void {
    console.log(`Base Price: ${order.basePrice}`)
    console.log(`Discount: ${(1 - order.discountFactor) * 100}%`)
    console.log(`Final: ${order.getPrice()}`)
  }
}
```

**When NOT to replace:**
- Variable is used once and extraction adds no clarity
- Calculation is expensive and would be repeated (use memoization or keep temp)
- Variable represents an intermediate step in a complex algorithm

**Performance consideration:**

```typescript
// If worried about repeated calculation
class Order {
  private _basePrice: number | null = null

  get basePrice(): number {
    if (this._basePrice === null) {
      this._basePrice = this.quantity * this.itemPrice
    }
    return this._basePrice
  }

  // Invalidate cache when data changes
  set quantity(value: number) {
    this._quantity = value
    this._basePrice = null
  }
}
```

Reference: [Replace Temp with Query](https://refactoring.com/catalog/replaceTempWithQuery.html)
