---
title: Document That Clients Must Tolerate Unknown Fields, Events, and Enum Values
impact: HIGH
impactDescription: prevents additive changes (the safe kind) from breaking existing clients
tags: ver, compatibility, clients, tolerance
---

## Document That Clients Must Tolerate Unknown Fields, Events, and Enum Values

Several change classes are listed as backwards-compatible specifically because clients are expected to tolerate them: new response fields, new event types, new enum values. This obligation has to be **documented prominently** — not buried in a versioning page — because client behaviour determines whether your additive change is actually additive. A client that uses strict schema validation (rejecting unknown fields) experiences your "additive" change as a breaking one.

The contract goes both ways: the API team agrees never to ship breaking changes without a version bump; clients agree to write tolerant code. The clearer this contract is upfront, the fewer false-breaking-change incidents you see.

**What clients must tolerate (and why):**

| Addition | Why clients must tolerate |
|----------|--------------------------|
| New top-level response fields | API team adds `risk_score` to charge responses; old SDKs should ignore it |
| New nested object fields | API team adds `card.three_d_secure_authentication` inside `card`; same principle |
| New event types in webhooks | API team adds `charge.dispute.funds_withdrawn`; handlers without a case for it should no-op |
| New values in enums marked "extensible" | API team adds `decline_code: "fraudulent"`; clients should fall back to the type-level handler |
| New error codes | API team adds `code: "card_velocity_exceeded"`; clients should fall back to `type` |
| New webhook payload fields | API team adds `event.data.previous_attributes`; clients that don't read it are unaffected |

**Incorrect (client uses strict schema validation):**

```python
from pydantic import BaseModel, Extra

class Charge(BaseModel):
    class Config:
        extra = Extra.forbid  # reject unknown fields

    id: str
    object: str
    amount: int
    currency: str

# API ships a backwards-compatible change adding `risk_score`:
charge = Charge.parse_obj(response_json)
# → ValidationError: extra fields not permitted (risk_score)
```

```text
// API team ships an additive change → client crashes.
// API team learns to never ship "additive" changes because they break clients.
// Versioning machinery is wasted.
```

**Correct (client tolerates unknown fields):**

```python
class Charge(BaseModel):
    class Config:
        extra = Extra.allow  # accept and preserve unknown fields

    id: str
    object: str
    amount: int
    currency: str

charge = Charge.parse_obj(response_json)
# `risk_score` is preserved on the model but ignored by code that doesn't reference it.
```

**Correct (webhook handler tolerates unknown event types):**

```python
def handle_event(event):
    handlers = {
        'charge.succeeded': on_charge_succeeded,
        'charge.refunded': on_charge_refunded,
        'invoice.paid': on_invoice_paid,
    }
    handler = handlers.get(event['type'])
    if handler:
        handler(event)
    else:
        # Unknown event type — log and ignore. NOT raise.
        logger.info('ignoring unhandled event type: %s', event['type'])
```

```text
// API team ships new event type charge.dispute.funds_withdrawn.
// This handler logs and ignores it gracefully.
// Adding handling for the new type is opt-in, not forced.
```

**Correct (enum fallback to type-level handling):**

```python
def handle_card_error(error):
    by_decline_code = {
        'insufficient_funds': prompt_for_different_card,
        'expired_card': prompt_for_new_expiry,
        'incorrect_cvc': prompt_for_cvc_retry,
    }
    handler = by_decline_code.get(error.get('decline_code'))
    if handler:
        handler(error)
    else:
        # Unknown decline_code — fall back to generic card_error handling
        prompt_for_different_card(error)
```

**Document the contract in your SDK docs and your changelog:**

> **Forward-compatibility contract:** clients must tolerate the following additive changes without errors:
> 
> 1. New top-level and nested response fields — preserve them, ignore them, but do not reject the response.
> 2. New event types in webhook payloads — log and ignore unknown types.
> 3. New values in extensible enums (`decline_code`, `code`, `type` on errors, event types) — fall back to a default handler.
> 
> If your client library or schema validator rejects responses with unknown fields, configure it to allow extras. SDKs we publish are pre-configured to tolerate these additions.

**SDKs should be tolerant by default.** Strict mode is opt-in for debugging; production code uses tolerant deserialisation. This pushes the contract to where it can be enforced — your own SDK code — rather than relying on every integrator's choice.

**The contract limits what counts as additive.** Adding a field with semantics that break old clients (e.g., a new `status: "pending_review"` value that means "previously-`active` charges should now wait" — semantic change) is still breaking even though the field is new. Additive = "old clients ignoring it produces correct behaviour."

Reference: [Stripe upgrades — additive changes](https://docs.stripe.com/upgrades)
