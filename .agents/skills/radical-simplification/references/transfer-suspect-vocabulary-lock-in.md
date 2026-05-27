---
title: Suspect the surrounding vocabulary when stuck
tags: transfer, vocabulary, framing
---

## Suspect the surrounding vocabulary when stuck

A domain's vocabulary silently constrains the solution space to what that vocabulary can name. Once a thing is called a "Service", the next move is a "Repository" and a "Manager" — even when those abstractions are wrong for the actual work. By default the agent inherits whatever names are already on the page. When stuck, the first thing to suspect is that the names are wrong.

```text
A class called OrderService with 12 collaborators:
  OrderRepository, PaymentGateway, InventoryService, ShippingService,
  EmailService, AnalyticsService, RetryQueue, IdempotencyStore,
  FraudCheck, TaxCalculator, AuditLog, FeatureFlags.

Inside it: a 400-line method orchestrating a long state transition
with try/catch around each call. New requirements keep adding parameters.

What the names hint:
  - "Service" implies a stateless function on data.
  - This thing is stateful (transitions an order through phases).
  - Most of its complexity is orchestration, not service logic.

Drop the vocabulary, name what it actually is:
  - It is a workflow / saga / order lifecycle.
  - Workflow vocabulary brings: steps, compensations, durable state,
    each step's pre/post conditions.
  - Now the 400-line method becomes a workflow definition, the
    catches become compensations, the IdempotencyStore is the
    workflow runtime's job.

Same problem. Different vocabulary. The solution space the new
vocabulary opens did not exist in the old one.
```

A diagnostic: if you keep adding suffixes (`Handler`, `Manager`, `Coordinator`, `Helper`) to break out responsibilities, the original noun is wrong. Reach for a different vocabulary — workflow, stream, ledger, automaton, schema — and see what falls out.

If the new vocabulary also suggests a different way to split the system, follow it into [`decomp-orthogonal-axes`](decomp-orthogonal-axes.md) — the right vocabulary often reveals the right axes for free.

Reference: [Hadamard — The Psychology of Invention in the Mathematical Field (1945, Princeton UP)](https://en.wikipedia.org/wiki/The_Psychology_of_Invention_in_the_Mathematical_Field)
