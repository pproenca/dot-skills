---
title: Sign Webhook Deliveries with HMAC and a Timestamp Tolerance Window
impact: HIGH
impactDescription: prevents forged webhook calls and replay attacks
tags: ops, webhooks, security, hmac
---

## Sign Webhook Deliveries with HMAC and a Timestamp Tolerance Window

Every webhook delivery carries a signature header (`Stripe-Signature` in Stripe's case) containing a Unix timestamp and one or more HMAC-SHA256 signatures of the payload. The receiver recomputes the HMAC over `"{timestamp}.{raw_body}"` using a shared endpoint secret and compares with **constant-time** equality. The timestamp must also be within a tolerance window (Stripe defaults to 5 minutes) to reject replays of captured signed payloads.

Webhook endpoints are publicly addressable HTTP endpoints — without signing, anyone who guesses the URL can POST forged events. Signature verification proves the payload came from your server and hasn't been tampered with in transit. The timestamp check closes the replay attack vector: an attacker who captures a real signed payload can't replay it later.

**Incorrect (no signing — webhook endpoints are open POST handlers):**

```text
POST https://example.com/webhook
Content-Type: application/json

{ "id": "evt_X", "type": "charge.succeeded", "data": { "object": { "amount": 100000000, ... } } }
```

```text
// Attacker who knows the URL POSTs forged "charge.succeeded" events.
// Integrator's handler grants service, ships product, fulfils refunds based on lies.
// No way to distinguish real events from forged ones.
```

**Incorrect (URL secret as the only auth — leaks in logs):**

```text
POST https://example.com/webhook?secret=abc123
```

```text
// URL-embedded secrets leak via referer headers, server access logs, CDN logs, browser history.
// Rotation requires every integration to update the URL.
// Once leaked, anyone can POST forged events.
```

**Incorrect (signature without timestamp — replay attacks succeed forever):**

```text
POST https://example.com/webhook
X-Signature: hmac-sha256-of-body

{ "id": "evt_X", ... }
```

```text
// Attacker captures one valid signed delivery (in a log, packet capture, malicious endpoint).
// Replays it tomorrow, next week, next year — signature is still valid.
// Duplicate event arrival looks indistinguishable from at-least-once delivery.
```

**Correct (timestamped HMAC with constant-time comparison):**

```text
POST https://example.com/webhook
Content-Type: application/json
Stripe-Signature: t=1747699200,v1=5257a869e7ecebeda32affa62cdca3fa51cad7e77a0e56ff536d0ce8e108d8bd

{ "id": "evt_X", "type": "charge.succeeded", ... }
```

```python
# Receiver verification
import hmac, hashlib, time

ENDPOINT_SECRET = 'whsec_abc123...'
TOLERANCE_SECONDS = 300  # 5 minutes

def verify_webhook(raw_body: bytes, signature_header: str) -> dict:
    # Parse: "t=<timestamp>,v1=<hmac>"
    parts = dict(item.split('=', 1) for item in signature_header.split(','))
    timestamp = int(parts['t'])
    received_sig = parts['v1']

    # Reject if timestamp is outside tolerance window (replay protection)
    now = int(time.time())
    if abs(now - timestamp) > TOLERANCE_SECONDS:
        raise ValueError('webhook timestamp outside tolerance window')

    # Recompute HMAC over "{timestamp}.{raw_body}"
    signed_payload = f'{timestamp}.'.encode() + raw_body
    expected_sig = hmac.new(
        ENDPOINT_SECRET.encode(),
        signed_payload,
        hashlib.sha256
    ).hexdigest()

    # Constant-time comparison — prevents timing-oracle attacks
    if not hmac.compare_digest(expected_sig, received_sig):
        raise ValueError('invalid webhook signature')

    return json.loads(raw_body)
```

```text
// Signature: proves the payload came from your server and wasn't tampered with.
// Timestamp: proves the delivery is recent — replays > 5 min old are rejected.
// constant-time compare: prevents byte-by-byte timing attacks on the comparison.
```

**The signed payload is `"{timestamp}.{raw_body}"`** — not just the body. Including the timestamp in the signed input means an attacker can't move a valid signature to a different timestamp.

**Use the RAW request body**, not a parsed-and-reserialised version. JSON reserialisation may reorder keys, normalise whitespace, or strip null fields — any of which break signature verification. Capture the raw bytes before any parsing.

**Support signature rotation with multiple `v<n>=` values:**

```text
Stripe-Signature: t=1747699200,v1=<sig_with_old_secret>,v1=<sig_with_new_secret>
```

```text
// During rotation, the platform signs with both old and new secrets.
// Receivers that have either secret can verify. Rotation completes when receivers update; old secret is retired.
```

**Tolerance window is configurable per endpoint but bounded.** 5 minutes is a sensible default. Less than 1 minute punishes clients with clock skew; more than 15 minutes weakens replay protection meaningfully.

**Provide a webhook test tool** that lets integrators verify their signature logic before going live — Stripe's CLI does `stripe trigger payment_intent.succeeded` to fire a fully-signed test event to the integrator's local endpoint.

**Document the signature scheme in detail** including: the signing algorithm (HMAC-SHA256), the canonical signed payload format, the tolerance window, how to fetch and store the endpoint secret, and how rotation works. Webhook signing is one of the highest-bug areas of any integration — documentation pays for itself.

Reference: [Stripe webhook signing](https://docs.stripe.com/webhooks/signatures)
