---
title: Name lifecycle transitions as domain operations, not generic setters
tags: lang, lifecycle, operations, ubiquitous-language
---

## Name lifecycle transitions as domain operations, not generic setters

The wrong default is mutating lifecycle state through a generic mechanism — `order.setStatus(Status.CANCELLED)`, `update(invoice, { status: 'voided' })` — when the domain has a name for exactly that transition. The enum value itself proves the vocabulary exists; the generic setter erases it from the operation surface. What is lost is not style: the transition's guards and consequences (can a shipped order be cancelled? does cancelling release reserved stock?) have no named home, so they scatter to call sites or are skipped.

**Evidence of violation:** a call site in domain or application code that writes a **named** lifecycle state through a generic mutator — a `set*`/`update*` call or direct field assignment whose written value is one of the type's named states — on a type with two or more named states. Cite the call site and the state enum/union that names the transition the code refused to name.

**Carve-outs (must be cited to claim):** persistence hydration and mappers reconstituting state from storage or wire formats; admin or data-repair scripts clearly outside the domain flow; the internals of a generic state-machine interpreter that applies already-validated transitions — in each case, cite the location proving the code is that thing.

**Incorrect (the transition's name and rules have no home):**

```ts
// application/cancel-order.ts
if (order.status !== "shipped") {
  order.setStatus(OrderStatus.CANCELLED)   // guard lives at the call site
  releaseReservations(order)               // consequence hopefully remembered everywhere
}
```

**Correct (the domain's verb owns its guard and consequences):**

```ts
// domain/order.ts
cancel(): void {
  if (this.status === "shipped") {
    throw new OrderAlreadyShippedError(this.id)
  }
  this.status = OrderStatus.CANCELLED
  this.reservations.forEach((r) => r.release())
}
```

Reference: [Martin Fowler — AnemicDomainModel](https://martinfowler.com/bliki/AnemicDomainModel.html), [Eric Evans — Domain-Driven Design Reference: Intention-Revealing Interfaces](https://www.domainlanguage.com/ddd/reference/)
