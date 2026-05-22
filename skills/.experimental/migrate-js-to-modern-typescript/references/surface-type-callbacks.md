---
title: Type Callback and Higher-Order Parameters
impact: HIGH
impactDescription: prevents any-propagation through callbacks
tags: surface, callbacks, higher-order, inference
---

## Type Callback and Higher-Order Parameters

An untyped callback parameter is implicitly `any`, which spreads to every handler body and every caller — defeating type checking across the entire call graph that flows through it. Typing the callback signature restores inference for all subscribers at once, so each handler is checked against the real event shape.

**Incorrect (untyped callback — every handler is unchecked):**

```typescript
// handler is implicitly any, so event and its fields are unchecked in
// every subscriber registered anywhere in the codebase.
function onPayment(handler) {
  bus.subscribe("payment", handler)
}
```

**Correct (typed callback signature):**

```typescript
interface PaymentEvent {
  orderId: string
  amountCents: number
}

function onPayment(handler: (event: PaymentEvent) => void): void {
  bus.subscribe("payment", handler)
}
```

Reference: [TypeScript Handbook: More on Functions](https://www.typescriptlang.org/docs/handbook/2/functions.html)
