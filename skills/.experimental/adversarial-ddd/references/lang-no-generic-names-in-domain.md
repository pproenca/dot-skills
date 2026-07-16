---
title: Name domain logic after the domain, not after mechanics
tags: lang, naming, domain-layer, generic-names
---

## Name domain logic after the domain, not after mechanics

The wrong default — especially in agent-authored code — is parking business rules in types named after code mechanics: `OrderManager`, `InvoiceHelper`, `PaymentProcessor`, `CustomerData`. These names are semantics-free: they tell the reader that code exists, not what the business does. Every rule that lands in a `*Manager` is a rule the ubiquitous language failed to name, and the vocabulary stops growing exactly where the domain is most complex.

**Evidence of violation:** a type or module in the domain layer whose name is, or ends in, one of: `Manager`, `Helper`, `Util`, `Utils`, `Processor`, `Data`, `Info`, `Item`, `Details`, `Common`, `Misc`, `Object` — AND that contains at least one business rule (a conditional branching on domain state, a calculation with business meaning). Both legs are required: a semantics-free name on a pure data-shuffling adapter is not this violation, and a business rule in a well-named type is not either.

**Carve-outs (must be cited to claim):** infrastructure adapters outside the domain layer (a `ConnectionManager` in the persistence module is idiomatic); framework-mandated names — cite the framework requirement. `*Service` is deliberately not on the list — a domain service is a legitimate DDD pattern for operations that belong to no single entity. `*Handler` is not on the list — it is idiomatic in event-driven code.

**Incorrect (the business's most important rule lives in a name that says nothing):**

```ts
// domain/order-manager.ts
export class OrderManager {
  process(order: Order): void {
    if (order.total.exceeds(order.customer.creditLimit)) {
      order.holdForReview() // credit policy — the domain's word for this is missing
    }
  }
}
```

**Correct (the rule's domain name surfaces, and enters the glossary):**

```ts
// domain/credit-policy.ts
export class CreditPolicy {
  applyTo(order: Order): void {
    if (order.total.exceeds(order.customer.creditLimit)) {
      order.holdForReview()
    }
  }
}
```

The "missing for PASS" must propose the domain name — it is almost always visible in what the conditional actually decides.

Reference: [Eric Evans — Domain-Driven Design Reference: Ubiquitous Language, Domain Services](https://www.domainlanguage.com/ddd/reference/), [Martin Fowler — AnemicDomainModel](https://martinfowler.com/bliki/AnemicDomainModel.html)
