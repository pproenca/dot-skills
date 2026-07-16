---
title: Keep business rules with the model they govern
tags: model, anemic-domain-model, invariants, encapsulation
---

## Keep business rules with the model they govern

The wrong default is the anemic split: a domain type that is a bag of publicly mutable fields, and a service somewhere else doing guard-then-mutate on it. The rules that define the concept live away from the concept, so nothing stops the next writer from mutating the fields without the guard — the model cannot defend its own meaning. The test is shape-based, not paradigm-based: in an FP codebase, rules expressed as pure functions in the same module as the struct they govern are "with the model".

**Evidence of violation:** both legs are required — (a) a domain type exposes raw mutation of rule-governed state (public setters or public mutable fields for lifecycle, balances, quantities); AND (b) a module other than the type's own enforces a business rule on that state by guard-then-mutate, or the same guard is duplicated at two or more call sites. Cite the exposed mutation and the external guard.

**Carve-outs (must be cited to claim):** DTOs, persistence records, wire-format types, and event records are not the domain model — the claim requires citing that no business rule anywhere in the target guards their fields. If a rule guards them somewhere, they are the model, and the violation stands.

**Incorrect (the rule lives where the model cannot enforce it):**

```ts
// domain/loyalty-account.ts
export class LoyaltyAccount {
  points = 0 // publicly mutable
}

// services/redemption-service.ts
export function redeem(account: LoyaltyAccount, cost: number): void {
  if (account.points < cost) {
    throw new InsufficientPointsError()
  }
  account.points -= cost // any other caller can skip the guard
}
```

**Correct (the model defends its own invariant):**

```ts
// domain/loyalty-account.ts
export class LoyaltyAccount {
  private points = 0

  redeem(cost: number): void {
    if (this.points < cost) {
      throw new InsufficientPointsError()
    }
    this.points -= cost
  }
}
```

Reference: [Martin Fowler — AnemicDomainModel](https://martinfowler.com/bliki/AnemicDomainModel.html), [Eric Evans — Domain-Driven Design Reference: Entities, Aggregates](https://www.domainlanguage.com/ddd/reference/)
