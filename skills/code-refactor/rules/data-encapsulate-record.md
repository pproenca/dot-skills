---
title: Encapsulate Record into Class
impact: MEDIUM
impactDescription: enables derived data and controlled mutation
tags: data, encapsulation, record, class
---

## Encapsulate Record into Class

When a plain data structure grows behavior or needs derived fields, convert it to a class. This centralizes logic and protects invariants.

**Incorrect (plain object with scattered logic):**

```typescript
interface Order {
  items: { productId: string; quantity: number; price: number }[]
  taxRate: number
  shippingCost: number
}

// Logic scattered across consumers
function getSubtotal(order: Order): number {
  return order.items.reduce((sum, item) => sum + item.price * item.quantity, 0)
}

function getTax(order: Order): number {
  return getSubtotal(order) * order.taxRate
}

function getTotal(order: Order): number {
  return getSubtotal(order) + getTax(order) + order.shippingCost
}

// Different module calculates subtotal differently (bug!)
function printReceipt(order: Order): void {
  const subtotal = order.items.reduce((sum, item) => sum + item.price, 0)  // Missing quantity!
  console.log(`Subtotal: ${subtotal}`)
}
```

**Correct (encapsulated in class):**

```typescript
class Order {
  private _items: OrderItem[] = []

  constructor(
    private readonly taxRate: number,
    private shippingCost: number
  ) {}

  addItem(productId: string, quantity: number, price: number): void {
    this._items.push(new OrderItem(productId, quantity, price))
  }

  get items(): readonly OrderItem[] {
    return [...this._items]
  }

  get subtotal(): number {
    return this._items.reduce((sum, item) => sum + item.total, 0)
  }

  get tax(): number {
    return this.subtotal * this.taxRate
  }

  get total(): number {
    return this.subtotal + this.tax + this.shippingCost
  }

  get itemCount(): number {
    return this._items.reduce((sum, item) => sum + item.quantity, 0)
  }
}

class OrderItem {
  constructor(
    public readonly productId: string,
    public readonly quantity: number,
    public readonly price: number
  ) {}

  get total(): number {
    return this.price * this.quantity
  }
}

// All consumers use the same calculation
function printReceipt(order: Order): void {
  console.log(`Subtotal: ${order.subtotal}`)  // Guaranteed correct
  console.log(`Tax: ${order.tax}`)
  console.log(`Total: ${order.total}`)
}
```

**Benefits:**
- Derived data calculated consistently
- Changes to calculation logic happen in one place
- Impossible to access stale or incorrect calculations

Reference: [Encapsulate Record](https://refactoring.com/catalog/encapsulateRecord.html)
