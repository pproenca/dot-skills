---
title: Translate external models at the boundary instead of absorbing them
tags: ctx, anticorruption-layer, integration, vendor-types
---

## Translate external models at the boundary instead of absorbing them

The wrong default is letting an external system's model become the domain model: storing the payment provider's response object as the payment, typing domain fields after the vendor's schema. The external model was designed for the vendor's domain, not yours — absorbing it means your ubiquitous language is now partly authored by a third party, and every vendor API change is a domain model change. DDD's anticorruption layer exists precisely to keep translation at the seam.

**Evidence of violation:** (a) a domain model type definition that imports or embeds a type from an external SDK or client package — cite the import inside the domain type's module; or (b) a raw external payload persisted or stored as domain state — field-for-field storage of the vendor's schema, vendor field names verbatim in a domain type (`charge_id`, `payment_intent_status` as domain fields). Cite the domain type and the external schema it mirrors.

**Carve-outs (must be cited to claim):** the adapter/integration module itself — the one place that talks to the vendor may of course use vendor types; cite that the module is the boundary and the types do not escape it. Raw payloads kept **outside the domain model** for audit or debugging (a `raw_webhook_events` log) are storage, not model — cite that no domain logic reads them.

**Incorrect (the vendor's model is now the domain model):**

```ts
// domain/payment.ts
import type { Stripe } from "stripe"

export class Payment {
  constructor(
    readonly intent: Stripe.PaymentIntent, // vendor object as domain state
  ) {}
}
```

**Correct (translation at the seam; the domain speaks its own language):**

```ts
// integrations/stripe/translate.ts — the anticorruption layer
export function toPayment(intent: Stripe.PaymentIntent): Payment {
  return Payment.of(PaymentId.parse(intent.id), toMoney(intent.amount, intent.currency), toPaymentState(intent.status))
}

// domain/payment.ts — no vendor imports
export class Payment {
  constructor(readonly id: PaymentId, readonly amount: Money, readonly state: PaymentState) {}
}
```

Reference: [Eric Evans — Domain-Driven Design Reference: Anticorruption Layer](https://www.domainlanguage.com/ddd/reference/), [Martin Fowler — BoundedContext](https://martinfowler.com/bliki/BoundedContext.html)
