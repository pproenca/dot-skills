---
title: Return 409 When a Key Is Reused with Different Params
impact: HIGH
impactDescription: prevents silent execution of unintended operations under retry
tags: idem, conflict, validation, error
---

## Return 409 When a Key Is Reused with Different Params

When a request arrives with an idempotency key that's been seen before but with *different* parameters, the server returns `409 Conflict` with `type: "idempotency_error"`. This is non-negotiable — "sending different parameters with the same idempotency key is a bug" (Brandur Leach). The server fails loudly because the alternatives — silently executing the new params, or silently returning the old response — both hide a real bug in the integrator's retry logic.

The check is implemented by hashing the request parameters at insert time and comparing on subsequent requests. If the hash matches, return the cached response (the normal idempotent path). If the hash doesn't match, return 409. Either way, the side effect happens at most once.

**Incorrect (silently re-execute with new params):**

```python
def post_charge(account_id, key, params):
    cached = get_cached(account_id, key)
    if cached and cached.params == params:
        return cached.response
    # Different params? Just execute again with the new ones.
    charge = create_charge(params)
    save_cached(account_id, key, params, charge)
    return charge
```

```text
// Bug: integrator's retry logic mutates the params between attempts (different amount? different source?).
// Server creates a charge with the WRONG amount, returns it as if everything's fine.
// Customer is charged incorrectly; no error signal anywhere.
```

**Incorrect (silently return old response even though params differ):**

```python
def post_charge(account_id, key, params):
    cached = get_cached(account_id, key)
    if cached:
        return cached.response  # ignore param differences
    ...
```

```text
// Integrator retries with new params expecting the new behaviour.
// Server returns the OLD response. Integrator thinks the new request succeeded; it didn't.
// Worst kind of bug: looks like success, isn't.
```

**Correct (hash the params, return 409 on mismatch):**

```python
def post_charge(account_id, key, params):
    params_hash = sha256(canonical_form(params))
    cached = get_cached(account_id, key)
    if cached:
        if cached.params_hash == params_hash:
            return cached.response  # idempotent replay — return cached
        else:
            return error_response(
                status=409,
                type='idempotency_error',
                code='idempotency_key_in_use',
                message=(
                    'Idempotency key "' + key + '" was previously used with '
                    'different parameters. Each retry must use the exact same '
                    'parameters as the original request.'
                ),
                doc_url='https://docs.example.com/error-codes/idempotency_key_in_use'
            )
    # First time with this key — store params hash and execute
    charge = create_charge(params)
    save_cached(account_id, key, params_hash, charge)
    return charge
```

**Wire response on conflict:**

```text
HTTP/1.1 409 Conflict
Content-Type: application/json
Request-Id: req_abc123

{
  "error": {
    "type": "idempotency_error",
    "code": "idempotency_key_in_use",
    "message": "Idempotency key '4ab9c8a1...' was previously used with different parameters. Each retry must use the exact same parameters as the original request.",
    "doc_url": "https://stripe.com/docs/error-codes/idempotency-key-in-use"
  }
}
```

**Why this is its own error `type`** (`idempotency_error`, not `invalid_request_error`): the action is unique. Retry is dangerous; surfacing to users is wrong (they didn't do anything); the right response is "fix the integration bug." Giving it a dedicated type forces integrators to handle it correctly. See [`error-four-type-enum`](error-four-type-enum.md).

**Canonical form for hashing:** sort fields lexicographically, normalise whitespace, exclude transient fields (timestamps, request IDs). The goal is "same logical request → same hash" regardless of serialisation order.

**Don't include the API version in the hash** — clients that upgrade their pinned version shouldn't get false 409s for retries of pre-upgrade requests.

**Concurrent requests with the same key** (request 2 arrives while request 1 is still executing): hold request 2 until request 1 completes (with a timeout), then return the cached response. Don't 409 — that would be a false positive.

Reference: [Brandur — idempotency key conflicts](https://brandur.org/idempotency-keys)
