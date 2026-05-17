---
title: Event Type Naming — `<resource>.<past_tense_action>`
impact: MEDIUM-HIGH
impactDescription: prevents inconsistent event-type strings that defeat generic routing
tags: ops, webhooks, naming, events
---

## Event Type Naming — `<resource>.<past_tense_action>`

Event types follow a strict naming pattern: `<resource>.<past_tense_action>`, all lowercase snake_case, dot-separated. Examples: `payment_intent.succeeded`, `customer.created`, `invoice.paid`, `charge.refunded`, `payment_method.attached`. The resource part is the singular form (`customer`, not `customers`); the action part is past-tense (`succeeded`, `created`, `refunded`) because the event represents something that has already happened.

Multi-level events use dots for hierarchy: `customer.subscription.created` (a subscription event on a customer). This naming is what lets clients route events with simple prefix matching (`if event.type.startsWith('customer.subscription.')`) and reduces the "new event type, new SDK update" surface area.

**Incorrect (inconsistent casing and tense):**

```text
chargeSucceeded                  # camelCase
charge-succeeded                 # kebab-case
CHARGE_SUCCEEDED                 # screaming snake
charge_succeed                   # not past tense
charge.success                   # noun not verb
chargeSuccessEvent               # vendor-prefix soup
charges.succeeded                # plural resource
```

```text
// Every event type uses a slightly different convention.
// Integrator's switch statement has to handle all of them.
// Pattern-matching breaks: handlers.startsWith('charge') matches both 'charge.succeeded' and 'chargeSucceeded'? No, it doesn't.
// Generic dispatchers across events become impossible.
```

**Incorrect (action-only, no resource — context lost):**

```text
succeeded
created
refunded
```

```text
// `succeeded` what? Payment? Onboarding? Verification?
// Forces handlers to inspect `data.object.object` to disambiguate.
// Routing tables become two-dimensional.
```

**Correct (`<resource>.<past_tense_action>` uniformly):**

```text
charge.succeeded
charge.failed
charge.refunded
charge.dispute.created
charge.dispute.funds_withdrawn
charge.dispute.funds_reinstated

customer.created
customer.updated
customer.deleted
customer.source.created
customer.source.updated
customer.subscription.created
customer.subscription.trial_will_end
customer.subscription.updated
customer.subscription.deleted

invoice.created
invoice.finalized
invoice.paid
invoice.payment_failed
invoice.upcoming
invoice.voided

payment_intent.created
payment_intent.requires_action
payment_intent.succeeded
payment_intent.payment_failed

payment_method.attached
payment_method.detached
payment_method.updated

setup_intent.created
setup_intent.succeeded
setup_intent.setup_failed
```

```text
// Pattern: <resource_singular>.<past_tense_action> — uniform across every event.
// Hierarchical events: <parent_resource>.<child_resource>.<action>
// Switch statements are readable: case 'invoice.paid', case 'invoice.payment_failed'
// Prefix matching works: handlers.routeStartsWith('customer.subscription.', subscriptionHandler)
```

**The naming rules:**

| Component | Rule | Example |
|-----------|------|---------|
| Separator | dot (`.`) — never underscore or dash | `charge.succeeded` |
| Resource | singular noun, snake_case | `payment_intent`, not `payment_intents` |
| Action | past-tense verb, snake_case | `succeeded`, `failed`, `created`, `attached` |
| Casing | all lowercase | never `Charge.Succeeded` |
| Hierarchy | dot-separated for parent.child relationships | `customer.subscription.created` |
| American English | always (see [`naming-american-english`](naming-american-english.md)) | `canceled` not `cancelled` |

**Past-tense matters** because events are notifications of things that have already happened. `charge.succeed` (present tense) sounds like a command; `charge.succeeded` (past tense) reads as a fact. The grammatical distinction is small but reinforces the event-vs-command mental model.

**Action verbs to standardise across resources:**

| Action | Meaning |
|--------|---------|
| `created` | resource came into existence |
| `updated` | resource modified |
| `deleted` | resource removed |
| `succeeded` | resource reached its successful terminal state |
| `failed` | resource reached an unsuccessful terminal state |
| `attached` / `detached` | relationship added/removed |
| `paid` / `refunded` / `voided` | financial state transitions |
| `requires_action` | the resource needs caller intervention to progress |

**Reuse the same verb across resources** when the semantic is the same: `customer.created`, `charge.created`, `invoice.created` all mean "this resource was just created." Don't invent synonyms (`customer.added`, `charge.opened`, `invoice.generated`) for the same concept.

**Adding new event types is backwards-compatible** if handlers tolerate unknown types gracefully — see [`ver-tolerate-unknown`](ver-tolerate-unknown.md). Renaming an existing event type is breaking and requires a version-change module.

Reference: [Stripe event types](https://docs.stripe.com/api/events/types)
