---
title: Accept Form-Encoded Requests, Always Return JSON
impact: HIGH
impactDescription: prevents JSON serialisation bugs in client code and makes curl trivial
tags: format, form-encoded, json, requests
---

## Accept Form-Encoded Requests, Always Return JSON

Request bodies are `application/x-www-form-urlencoded`. Response bodies are always `application/json`. The asymmetry is deliberate — form encoding makes curl-from-the-terminal trivial, sidesteps a long tail of JSON serialisation bugs in client code (`null` vs missing, integer overflow, key ordering), and works in every HTTP library without configuration. JSON is the right format for structured responses (nested objects, arrays of mixed types), but it's overkill for the flat key-value pairs that requests almost always are.

This choice also makes the API approachable. A developer copying a curl command from documentation can drop in their key and run it; there's no `Content-Type` to set, no body to escape, no client library required to debug a 400 response.

**Incorrect (JSON request body — heavier for a flat input):**

```text
POST /v1/charges HTTP/1.1
Content-Type: application/json

{
  "amount": 2000,
  "currency": "usd",
  "source": "tok_visa",
  "description": "Order #1234"
}
```

```text
// Requires client to set Content-Type, serialise to JSON, handle JSON parse errors.
// Curl one-liner needs --data-raw with escaped JSON.
// Common bugs: trailing commas, integer-as-string (`"amount": "2000"`), missing brackets.
```

**Correct (form-encoded request, JSON response):**

```text
POST /v1/charges HTTP/1.1
Content-Type: application/x-www-form-urlencoded

amount=2000&currency=usd&source=tok_visa&description=Order%20%231234
```

```text
// Trivial curl: curl https://api.stripe.com/v1/charges -u sk_test_X: -d amount=2000 -d currency=usd ...
// Works in every HTTP library — form encoding is the HTTP default body type.
// Response is JSON: { "id": "ch_3MqZ...", "object": "charge", "amount": 2000, ... }
```

**Optional sections of the wire format:**

| Aspect | Choice | Reason |
|--------|--------|--------|
| Request body | form-encoded | trivial curl, no JSON parse errors |
| Response body | JSON | structured, nested, typed |
| Nested request fields | bracket notation (`metadata[order_id]=...`) | see [`format-bracket-notation-nesting`](format-bracket-notation-nesting.md) |
| File uploads | `multipart/form-data` | only for binary content |

**Decision rule for new APIs in 2026:** form-encoded is the right default when imitating Stripe v1's resource API specifically (and gets you the curl ergonomics). For a fully JSON-native API (e.g., a modern internal-platform API with no curl-first audience, or one with genuinely rich nested request bodies that benefit from JSON's structure), accepting JSON for request bodies is acceptable — but commit to *one* format across the entire API surface. Mixed form-encoded and JSON requests across endpoints is the worst outcome; pick one. Stripe's own v2 API moves to JSON for endpoints that need rich nesting; the v1 resource API stays form-encoded.

Reference: [Stripe API root — request format](https://docs.stripe.com/api)
