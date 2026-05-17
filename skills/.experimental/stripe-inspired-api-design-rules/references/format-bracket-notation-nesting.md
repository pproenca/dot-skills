---
title: Use Bracket Notation for Nested Fields in Form Bodies
impact: MEDIUM-HIGH
impactDescription: prevents ambiguous nesting and supports arbitrary depth in form-encoded requests
tags: format, form-encoded, nesting, brackets
---

## Use Bracket Notation for Nested Fields in Form Bodies

Form-encoded bodies are flat key-value pairs, so nested structures use bracket notation in the key: `metadata[order_id]=6735`, `card[number]=4242...`, `shipping[address][line1]=510%20Townsend`. Arrays are expressed with `[]` suffix and repeated keys: `expand[]=customer&expand[]=payment_intent.customer`. The convention is consistent enough that any nested JSON request body has a mechanical translation into form-encoded brackets.

This matters because it preserves the form-encoded-request ergonomics ([`format-form-encoded-requests`](format-form-encoded-requests.md)) without giving up the ability to send structured data. Every Stripe SDK serialises nested objects to bracket notation transparently — integrators write idiomatic objects in their language and the SDK handles the encoding.

**Incorrect (flattened keys with custom delimiters):**

```text
POST /v1/customers HTTP/1.1
Content-Type: application/x-www-form-urlencoded

metadata_order_id=6735&metadata_referrer=affiliate&shipping_address_line1=510%20Townsend&shipping_address_city=SF
```

```text
// Custom underscore-delimited flattening — every consumer reinvents the parser.
// Ambiguous: `metadata_order_id` could mean `metadata.order_id` or `metadata_order.id`.
// SDKs cannot mechanically derive this from native nested objects.
```

**Incorrect (JSON-in-a-form-field workaround):**

```text
POST /v1/customers HTTP/1.1
Content-Type: application/x-www-form-urlencoded

metadata=%7B%22order_id%22%3A%226735%22%7D&shipping=%7B%22address%22%3A%7B%22line1%22%3A%22510%20Townsend%22%7D%7D
```

```text
// JSON-escaped inside a form field — worst of both worlds.
// Server has to JSON-parse individual fields. Defeats the form-encoded ergonomics.
```

**Correct (bracket notation, recursive):**

```text
POST /v1/customers HTTP/1.1
Content-Type: application/x-www-form-urlencoded

metadata[order_id]=6735&metadata[referrer]=affiliate&shipping[address][line1]=510%20Townsend&shipping[address][city]=SF
```

```text
// Unambiguous nesting. Recursive — works to any depth.
// SDKs mechanically translate nested objects: { metadata: { order_id: "6735" } }
//   → metadata[order_id]=6735
```

**Correct (arrays with `[]` suffix and repeated keys):**

```text
POST /v1/charges/ch_X?expand[]=customer&expand[]=invoice.subscription
```

```text
// Each expand value is a repeated `expand[]=` parameter.
// Order is preserved; the server sees a list, not a single value.
```

**Curl example:**

```text
curl https://api.stripe.com/v1/customers \
  -u sk_test_X: \
  -d "metadata[order_id]=6735" \
  -d "shipping[address][line1]=510 Townsend" \
  -d "shipping[address][city]=SF"
```

Reference: [Stripe metadata docs](https://docs.stripe.com/api/metadata)
