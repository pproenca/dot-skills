---
title: Give each name exactly one meaning within a context
tags: lang, ubiquitous-language, homonyms, bounded-context
---

## Give each name exactly one meaning within a context

The wrong default is letting a convenient word absorb a second concept — `Account` meaning both the login identity and the billing ledger, `status` holding order states in one path and payment states in another. Homonyms are worse than synonyms: code that reads correctly does the wrong thing, and every conversation about the term needs a disambiguating clause. Within one bounded context each term has one unambiguous meaning; when one word legitimately means two things, that is the signal for two contexts, not one overloaded name.

**Evidence of violation:** within one context, (a) two declarations share a name but have structurally different shapes serving different concepts — two `Account` types, one with credentials and one with balances; or (b) one field or variable holds value sets from two different concepts on different code paths — cite both assignments (`record.status = OrderStatus.SHIPPED` in one branch, `record.status = PaymentStatus.DECLINED` in another).

**Carve-outs (must be cited to claim):** the same name in **different bounded contexts** is exactly how DDD says it should work — a `Customer` in Support and a `Customer` in Billing may differ freely; cite the context boundary (separate top-level module, package, or service) to claim this.

**Incorrect (one word, two concepts, one context):**

```ts
// accounts/account.ts
export type Account = { email: string; passwordHash: string }

// accounts/billing.ts — same context, same word, different concept
export type Account = { balance: Money; creditLimit: Money }
```

**Correct (each concept gets its own term):**

```ts
// accounts/login-identity.ts
export type LoginIdentity = { email: string; passwordHash: string }

// accounts/billing-account.ts
export type BillingAccount = { balance: Money; creditLimit: Money }
```

The "missing for PASS" names the split: which occurrence keeps the term, and what the other concept is called — drawn from the glossary when one exists.

Reference: [Martin Fowler — BoundedContext](https://martinfowler.com/bliki/BoundedContext.html), [Eric Evans — Domain-Driven Design Reference](https://www.domainlanguage.com/ddd/reference/)
