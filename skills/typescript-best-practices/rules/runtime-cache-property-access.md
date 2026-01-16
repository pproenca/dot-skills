---
title: Cache Property Access in Loops
impact: LOW-MEDIUM
impactDescription: reduces property lookups by N×
tags: runtime, loops, caching, property-access, optimization
---

## Cache Property Access in Loops

Repeated property access inside loops adds overhead. Cache frequently accessed properties before the loop, especially for nested properties and array lengths.

**Incorrect (repeated property access):**

```typescript
function processOrders(orders: Order[], config: AppConfig): ProcessedOrder[] {
  const results: ProcessedOrder[] = []

  for (let i = 0; i < orders.length; i++) {  // orders.length accessed each iteration
    const tax = orders[i].total * config.tax.rate  // Nested access each time
    const shipping = config.shipping.rates[orders[i].region]  // Multiple nested accesses

    results.push({
      ...orders[i],
      tax,
      shipping,
      final: orders[i].total + tax + shipping
    })
  }

  return results
}
```

**Correct (cached property access):**

```typescript
function processOrders(orders: Order[], config: AppConfig): ProcessedOrder[] {
  const results: ProcessedOrder[] = []
  const { length } = orders
  const { rate: taxRate } = config.tax
  const { rates: shippingRates } = config.shipping

  for (let i = 0; i < length; i++) {
    const order = orders[i]
    const tax = order.total * taxRate
    const shipping = shippingRates[order.region]

    results.push({
      ...order,
      tax,
      shipping,
      final: order.total + tax + shipping
    })
  }

  return results
}
```

**For functional loops:**

```typescript
// Property access is implicit but still repeated
orders.forEach(order => {
  const tax = order.total * config.tax.rate
})

// Cache outside the callback
const taxRate = config.tax.rate
orders.forEach(order => {
  const tax = order.total * taxRate
})
```

**When this matters:**
- Large arrays (1000+ items)
- Hot paths executed frequently
- Deeply nested property access

**When to skip optimization:**
- Small arrays or infrequent execution
- When readability suffers significantly
- Modern engines optimize many common patterns

Reference: [V8 Hidden Classes](https://v8.dev/blog/fast-properties)
