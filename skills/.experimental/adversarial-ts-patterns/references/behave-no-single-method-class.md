---
title: Pass a function, not a stateless single-method class, for Strategy and Command
tags: behave, strategy, command, first-class-functions, gof
---

## Pass a function, not a stateless single-method class, for Strategy and Command

The wrong default is the class-shaped Strategy or Command — an interface with exactly one method (`execute`, `run`, `handle`, `calculate`) and a stateless class per variant. Those patterns are workarounds for languages without first-class functions; in TypeScript the interface **is** a function type, and each "concrete strategy" is a function or closure. The class version triples the token count, forces `new` at every use site, and makes the simplest composition (wrapping, partial application) awkward.

**Evidence of violation:** an interface or abstract class declaring exactly one method, implemented by two or more classes that hold no instance state (constructor-injected dependencies used only inside that one method count as closure captures, not state). The carve-out is a genuine multi-member contract — a Command that also carries `undo()` or serializes itself for a persistent queue holds state and behavior together, and the class form earns its place.

**Incorrect (three classes for three functions):**

```ts
interface ShippingStrategy {
  calculate(order: Order): number
}
class FlatRateShipping implements ShippingStrategy {
  calculate(order: Order) { return 5 }
}
class WeightBasedShipping implements ShippingStrategy {
  calculate(order: Order) { return order.weightKg * 1.2 }
}
```

**Correct (the contract is a function type):**

```ts
type ShippingStrategy = (order: Order) => number

const flatRateShipping: ShippingStrategy = () => 5
const weightBasedShipping: ShippingStrategy = (order) => order.weightKg * 1.2
```

Reference: [Refactoring Guru — Strategy (functional alternative via lambdas)](https://refactoring.guru/design-patterns/strategy)
