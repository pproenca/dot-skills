---
title: Carry domain concepts in domain types, not interchangeable primitives
tags: model, value-objects, primitive-obsession, type-safety
---

## Carry domain concepts in domain types, not interchangeable primitives

The wrong default is passing domain concepts around as bare strings and numbers. Two account ids of type `string` are swappable at every call site; an amount of type `number` silently mixes currencies. The value-object move — a small named type per concept — makes the domain's distinctions machine-checked and gives the ubiquitous language a place to live in signatures.

**Evidence of violation:** any of — (a) a domain type for the concept **exists in the target** but an API bypasses it with the raw primitive (`OrderId` is defined; `shipOrder(orderId: string)` takes the bare string); (b) a signature takes two or more parameters of the same primitive type that each denote a **domain identifier of a different entity** — names ending in `Id`, `Code`, `Number` referencing distinct types (`transfer(fromAccountId: string, toAccountId: string, ...)`); or (c) a monetary or measured quantity carried as a bare number with no currency or unit in the same type — cite the field and the absence.

**Carve-outs (must be cited to claim):** serialization and boundary code converting to or from wire formats, where primitives are the medium — cite the boundary (a codec, a route handler unpacking a request, a DB row mapper). The carve-out covers the conversion site only, not the domain signatures behind it.

**Incorrect (the compiler cannot see the domain's distinctions):**

```ts
export function transfer(
  fromAccountId: string,
  toAccountId: string,
  amount: number, // in what currency?
): void { /* ... */ }
// transfer(to, from, amount) compiles and inverts the money flow
```

**Correct (a swapped argument no longer type-checks):**

```ts
export function transfer(
  from: AccountId,
  to: AccountId,
  amount: Money, // { amount: 250_00, currency: "EUR" }
): void { /* ... */ }
```

The "missing for PASS" names the value type to introduce (or the existing one being bypassed) and the signatures to move onto it.

Reference: [Martin Fowler — ValueObject](https://martinfowler.com/bliki/ValueObject.html), [Eric Evans — Domain-Driven Design Reference: Value Objects](https://www.domainlanguage.com/ddd/reference/)
