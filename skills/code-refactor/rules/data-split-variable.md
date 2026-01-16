---
title: Split Variable with Multiple Assignments
impact: MEDIUM
impactDescription: clarifies intent and prevents confusion from reused variables
tags: data, split-variable, clarity, single-assignment
---

## Split Variable with Multiple Assignments

When a variable is assigned multiple times for different purposes, split it into separate variables. Each variable should have a single clear purpose.

**Incorrect (variable reused for different purposes):**

```typescript
function calculateShipping(order: Order): number {
  let temp = order.items.reduce((sum, item) => sum + item.weight, 0)  // temp is total weight
  temp = temp * 0.5  // temp is now base shipping cost
  temp = temp + 5  // temp is now shipping cost with handling fee

  if (order.destination.isRemote) {
    temp = temp * 1.5  // temp is now adjusted for remote
  }

  temp = Math.max(temp, 10)  // temp is now minimum shipping
  temp = Math.min(temp, 100)  // temp is now capped shipping

  return temp
}

// What does 'temp' represent at any given line? Impossible to know at a glance
```

**Correct (separate variables with clear purposes):**

```typescript
function calculateShipping(order: Order): number {
  const totalWeight = order.items.reduce((sum, item) => sum + item.weight, 0)
  const baseShippingCost = totalWeight * 0.5
  const costWithHandling = baseShippingCost + 5

  const adjustedCost = order.destination.isRemote
    ? costWithHandling * 1.5
    : costWithHandling

  const MIN_SHIPPING = 10
  const MAX_SHIPPING = 100
  const finalCost = Math.min(Math.max(adjustedCost, MIN_SHIPPING), MAX_SHIPPING)

  return finalCost
}

// Each variable has one clear meaning throughout its scope
```

**Alternative (pure function composition):**

```typescript
function calculateShipping(order: Order): number {
  const totalWeight = calculateTotalWeight(order.items)
  const baseCost = calculateBaseCost(totalWeight)
  const adjustedCost = adjustForDestination(baseCost, order.destination)
  return applyShippingBounds(adjustedCost)
}

function calculateTotalWeight(items: OrderItem[]): number {
  return items.reduce((sum, item) => sum + item.weight, 0)
}

function calculateBaseCost(weight: number): number {
  const HANDLING_FEE = 5
  return weight * 0.5 + HANDLING_FEE
}

function adjustForDestination(cost: number, destination: Destination): number {
  return destination.isRemote ? cost * 1.5 : cost
}

function applyShippingBounds(cost: number): number {
  return Math.min(Math.max(cost, 10), 100)
}
```

**Benefits:**
- Each variable's meaning is immediately clear
- Easier to debug - inspect any variable at any point
- Prevents accidental use of stale value

Reference: [Split Variable](https://refactoring.com/catalog/splitVariable.html)
