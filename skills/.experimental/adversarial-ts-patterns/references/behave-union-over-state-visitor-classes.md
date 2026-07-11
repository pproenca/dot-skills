---
title: Use a discriminated union and match function, not State or Visitor class hierarchies, over closed sets
tags: behave, state-pattern, visitor, discriminated-union, gof
---

## Use a discriminated union and match function, not State or Visitor class hierarchies, over closed sets

The wrong default is the GoF State pattern (a class per state, transitions via `context.setState(new NextState())`) or Visitor (`accept()`/`visitX()` double dispatch) for a set of states or node kinds that is closed within the application. Both patterns simulate what TypeScript expresses directly — a discriminated union plus a function that switches on the tag. The class hierarchies scatter one decision across N files, hide the transition table inside method bodies, and give up the union's headline guarantee, compile-time exhaustiveness when a member is added.

**Evidence of violation:** a class hierarchy where each subclass represents one state of a machine and transitions assign new state instances to a context, or paired `accept(visitor)`/`visit*(node)` methods traversing a node hierarchy — where the full set of states/nodes is defined inside the codebase under review. The carve-out is a genuinely open set extended across package boundaries (third-party plugins add new node classes the core never sees); exhaustive matching is impossible there by construction.

**Incorrect (transition table hidden in class bodies):**

```ts
abstract class OrderState {
  abstract next(ctx: OrderContext): void
}
class PendingState extends OrderState {
  next(ctx: OrderContext) { ctx.setState(new PaidState()) }
}
class PaidState extends OrderState {
  next(ctx: OrderContext) { ctx.setState(new ShippedState()) }
}
```

**Correct (the machine is data; matches are exhaustive):**

```ts
type OrderState = { status: "pending" } | { status: "paid" } | { status: "shipped" }

function next(state: OrderState): OrderState {
  switch (state.status) {
    case "pending": return { status: "paid" }
    case "paid":    return { status: "shipped" }
    case "shipped": return state
    default:        return assertNever(state)
  }
}
```

Reference: [TypeScript Handbook — Narrowing (discriminated unions and exhaustiveness)](https://www.typescriptlang.org/docs/handbook/2/narrowing.html#discriminated-unions)
