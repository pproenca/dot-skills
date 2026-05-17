---
title: Encapsulate Each Breaking Change in a Version-Change Module
impact: MEDIUM-HIGH
impactDescription: prevents version-conditional logic from sprawling through the codebase
tags: ver, transformation, modules, architecture
---

## Encapsulate Each Breaking Change in a Version-Change Module

Each breaking change between two adjacent dated versions is implemented as a self-contained **version-change module** with three parts: (1) documentation describing the change, (2) a request transformer (newer-shape → older-shape, applied when an old-pinned client sends a new-shape-style request — usually a no-op since old clients send old shapes), and (3) a response transformer (newer-shape → older-shape, applied when an old-pinned client receives a response generated in the new shape). Internally, the server always works in the newest version's shape; the version-change modules translate at the edge.

This architecture matters enormously at scale. Without it, every endpoint accumulates `if (version < '2024-10-28') { ... }` branches scattered through business logic; six versions later, the codebase is unmaintainable. With version-change modules, the breaking change lives in one file, the business logic stays clean, and adding a new version means writing one new module — not editing fifty existing files.

**Incorrect (version checks scattered through business logic):**

```python
def get_customer(customer_id, account_version):
    customer = db.get_customer(customer_id)
    response = customer.to_dict()
    if account_version < '2024-10-28':
        response['verified'] = response.pop('status') == 'verified'
    if account_version < '2024-05-15':
        response.pop('payment_method', None)
    if account_version < '2023-11-01':
        response['default_card'] = response.get('default_payment_method')
    if account_version < '2023-08-22':
        # ... and so on, forever
    return response
```

```text
// Every endpoint has this kind of conditional ladder.
// Forgetting to update one endpoint when adding a new version → silent compat bug.
// Old version code is interleaved with new — hard to delete old versions safely.
```

**Correct (one module per version-to-version transition):**

```python
# versions/v2024_10_28.py
class V20241028:
    description = "Customer.verified renamed to Customer.status"

    @staticmethod
    def request_transform(endpoint, params):
        # Old-pinned account sends `verified=true` → translate to `status=verified`
        if endpoint == 'POST /v1/customers' and 'verified' in params:
            params['status'] = 'verified' if params.pop('verified') else 'pending'
        return params

    @staticmethod
    def response_transform(endpoint, response):
        # Internal shape has `status`; old-pinned account expects `verified`
        if response.get('object') == 'customer' and 'status' in response:
            response['verified'] = response.pop('status') == 'verified'
        return response

    affected_resources = ['customer']
```

```python
# Edge middleware
def serialize_response(response, account_version):
    # Internal shape is always the newest. Walk backwards through versions
    # newer than the account's pin, applying response transforms.
    for version in versions_newer_than(account_version):
        response = version.response_transform(endpoint, response)
    return response
```

```text
// Endpoint code is clean — always works in the newest shape.
// Adding a new version: write one module, register it, done.
// Removing an old version: delete the module, run regression tests.
```

**The transformation chain is mechanical:**

```text
Internal shape (always newest)
  ↓ apply response_transform for version 2025-04-30 → 2025-01-15
  ↓ apply response_transform for version 2025-01-15 → 2024-10-28
  ↓ apply response_transform for version 2024-10-28 → 2024-05-15
  ↓ stop when we reach the account's pinned version
Output shape (the version the account asked for)
```

**Version-change modules also drive documentation generation.** The `description` field becomes the changelog entry. The `affected_resources` field enables "what changed between version X and version Y" queries.

**Test every version-change module both directions** (newer → older for responses, older → newer for requests), and test that the chain composes correctly across multiple intermediate versions.

**A version-change module is the unit of code review for a breaking change.** Reviewers can see exactly what the wire shape difference is, what gets transformed where, and whether the transformer handles edge cases (`null`, missing field, type changed).

**This pattern was originally described by Brandur Leach (Stripe).** The architecture is well-suited to dynamically-typed languages where dict-walking transformers are cheap; in statically-typed languages, the transformers operate on JSON ASTs at the edge before SDK deserialisation.

Reference: [Brandur — API versioning at Stripe](https://brandur.org/api-versioning), [Stripe API versioning blog](https://stripe.com/blog/api-versioning)
