---
title: Model lifecycles as the domain's named states, not boolean flag piles
tags: model, lifecycle, state-modeling, impossible-states
---

## Model lifecycles as the domain's named states, not boolean flag piles

The wrong default is accreting one boolean (or one nullable timestamp) per condition — `isPaid`, `isCancelled`, `shippedAt` — for a lifecycle whose states are mutually exclusive. Two flags encode four representable combinations for at most three legal states, and the "can't happen" combination eventually happens. Just as damaging for the language: the domain's state names — the words stakeholders use — vanish from the model, replaced by flag algebra (`isPaid && !isCancelled && shippedAt == null`) that must be re-derived at every reading.

**Evidence of violation:** two or more boolean fields, or nullable markers used as state (`cancelledAt != null` standing for "cancelled"), on one type encoding a single mutually exclusive lifecycle — the tell is that no legal path sets two of them at once, or that code checks combinations of them to derive which state the object is in. Cite the fields and one combination-checking site.

**Carve-outs (must be cited to claim):** flags that genuinely vary independently (`isGiftWrapped` and `isExpressShipping`) — cite a legal state with both set. Timestamps kept **alongside** a named status field as audit data are fine; the violation is when the timestamps are the only encoding of the state.

**Incorrect (four flags, one implicit state machine, no state names):**

```ts
export class Subscription {
  isTrial = false
  isActive = false
  isPaused = false
  cancelledAt: Date | null = null
}
// { isTrial: true, isActive: true, cancelledAt: set } is representable;
// which state is that?
```

**Correct (the domain's own state names, illegal combinations unrepresentable):**

```ts
export type SubscriptionState =
  | { status: "trial"; endsAt: Date }
  | { status: "active"; renewsAt: Date }
  | { status: "paused"; resumesAt: Date | null }
  | { status: "cancelled"; cancelledAt: Date }
```

In languages without tagged unions, a single status enum plus per-state data achieves the same: one field answers "which state", and its values are glossary words.

Reference: [Eric Evans — Domain-Driven Design Reference: making implicit concepts explicit](https://www.domainlanguage.com/ddd/reference/), [react.dev — Choosing the State Structure (avoid contradictions in state)](https://react.dev/learn/choosing-the-state-structure#avoid-contradictions-in-state)
