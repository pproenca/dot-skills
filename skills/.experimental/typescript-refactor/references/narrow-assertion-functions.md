---
title: Use Assertion Functions for Precondition Checks
impact: CRITICAL
impactDescription: narrows types while validating invariants in a single call
tags: narrow, assertion-functions, preconditions, invariants
---

## Use Assertion Functions for Precondition Checks

Assertion functions combine runtime validation with compile-time narrowing. After the assertion call, TypeScript narrows the type for the rest of the scope — no need for separate `if` checks or `as` casts.

**Incorrect (manual check-and-throw repeated everywhere):**

```typescript
function processOrder(order: Order | null) {
  if (order === null) {
    throw new Error("Order is required")
  }
  sendConfirmation(order) // Narrowed, but pattern duplicated across functions
}

function shipOrder(order: Order | null) {
  if (order === null) {
    throw new Error("Order is required")
  }
  createShipment(order) // Same check-and-throw copied again
}
```

**Correct (assertion function, reusable and composable):**

```typescript
function assertDefined<T>(value: T | null | undefined, name: string): asserts value is T {
  if (value === null || value === undefined) {
    throw new Error(`${name} is required`)
  }
}

function processOrder(order: Order | null) {
  assertDefined(order, "order")
  sendConfirmation(order) // Narrowed to Order
}

function shipOrder(order: Order | null) {
  assertDefined(order, "order")
  createShipment(order) // Same narrowing, no duplication
}
```

**Note:** Assertion functions work with `asserts value is T` and `asserts condition`. Use them for shared preconditions across multiple functions.

Reference: [TypeScript 3.7 - Assertion Functions](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-3-7.html)
