---
title: Name code after the glossary's terms, not private synonyms
tags: gloss, ubiquitous-language, naming, conformance
---

## Name code after the glossary's terms, not private synonyms

The wrong default is treating the glossary as documentation and the code as free territory. The ubiquitous language only stays ubiquitous if the code is bound to it: the moment an identifier introduces a private synonym for a defined term, the team reads one word and says another, and the glossary starts lying. In DDD the model and the language are the same thing — a code name that contradicts the glossary is a model change nobody agreed to.

**Evidence of violation:** a recorded glossary exists, and any of — (a) an identifier in the target names a concept the glossary defines under a different term — cite the glossary entry and the diverging identifier (`docs/ubiquitous-language.md` defines "Credit Note"; the code declares `class RefundVoucher` for the same negative-correction concept, proven by its fields or usage); (b) an identifier reuses a glossary term for a different concept than the entry defines — cite the entry and the contradicting usage; or (c) an entry asserts **defining content** — a fact a stakeholder would rely on — that the code bound to the term does not carry (the entry says "Settlement records which payment cleared it" while the `Settlement` type holds no payment reference) — cite the entry's clause and the type that lacks it. A glossary that over-promises about the model is drift in the recorded language; the fix may go either way (extend the model, or amend the entry), but the divergence is a FAIL until they agree. N/A when no glossary exists (that is `gloss-language-recorded`'s FAIL, not this rule's).

**Carve-outs (must be cited to claim):** framework- or protocol-imposed names at boundaries (an ORM table name, a wire-format field kept for API compatibility) when the glossary entry records the alias ("stored as `refund_vouchers` for legacy schema compatibility"). An alias claimed but not recorded in the glossary does not excuse the divergence — fail closed.

**Incorrect (glossary says one thing, code says another):**

```ts
// docs/ubiquitous-language.md: "Credit Note — a negative correction to an issued Invoice"
export class RefundVoucher {
  constructor(
    readonly invoiceId: InvoiceId,
    readonly amount: Money, // negative correction, per the Credit Note definition
  ) {}
}
```

**Correct (code speaks the recorded language):**

```ts
export class CreditNote {
  constructor(
    readonly invoiceId: InvoiceId,
    readonly amount: Money,
  ) {}
}
```

Reference: [Martin Fowler — UbiquitousLanguage](https://martinfowler.com/bliki/UbiquitousLanguage.html), [Eric Evans — Domain-Driven Design Reference](https://www.domainlanguage.com/ddd/reference/)
