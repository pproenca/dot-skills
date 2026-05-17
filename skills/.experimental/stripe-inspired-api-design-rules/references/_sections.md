# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

Categories are ordered by **design propagation impact** — how irreversibly a wrong decision cascades. Early decisions (resource shape, URL structure) lock in every endpoint, every SDK, every client integration; changing them later forces a new major API version. Later categories (naming, operational surface) are pervasive but locally scoped.

---

## 1. Resource Modeling & Identifiers (resource)

**Impact:** CRITICAL  
**Description:** Identifier scheme, type discriminators, and the wire shape of dates, money, and currency. These decisions appear on every object the API ever returns — getting them wrong forces a coordinated migration of every endpoint and every SDK.

## 2. URL Structure & HTTP Semantics (url)

**Impact:** CRITICAL  
**Description:** URL pluralization, HTTP verb conventions, action endpoints, and single-object semantics. Once SDKs ship and integrators wire routes into their codebases, the URL shape is effectively frozen.

## 3. Request & Response Format (format)

**Impact:** HIGH  
**Description:** Wire encoding (form-encoded requests, JSON responses), list envelope shape, cursor pagination, and the `expand` mechanism for inlining related resources. Defines the contract every client parser depends on.

## 4. Errors & Status Codes (error)

**Impact:** HIGH  
**Description:** Top-level error object shape, the small fixed `type` enum, HTTP status mapping, and the rule that `message` is mandatory while `code` is optional. Clients build their error handling once against this shape and reuse it across every endpoint.

## 5. Idempotency & Safe Retries (idem)

**Impact:** HIGH  
**Description:** `Idempotency-Key` header semantics, scoping rules, TTL, key-reuse-with-different-params detection, and recovery-point patterns for multi-step operations. Without idempotency from day one, retries cause duplicate charges and transfers — retrofitting after the first incident is brutal.

## 6. Versioning & Backwards Compatibility (ver)

**Impact:** HIGH  
**Description:** Date-based version strings, account pinning, the strict definition of what counts as a backwards-compatible change, and version-change modules that transform responses between versions. The wrong versioning model forces `/v2/` endpoints and parallel SDK universes.

## 7. Naming, Polymorphism & Metadata (naming)

**Impact:** MEDIUM-HIGH  
**Description:** snake_case wire format, American English spelling, type-discriminated polymorphism, the customer-defined `metadata` pattern, and the preference for enums over booleans on new properties. Per-field guidance that compounds across the surface — every renamed field is a breaking change.

## 8. Authentication, Webhooks & Search (ops)

**Impact:** MEDIUM-HIGH  
**Description:** Mode-and-scope-prefixed API keys (`sk_live_`, `pk_test_`, `rk_`), HTTPS-only Basic Auth, `Stripe-Account` header for multi-tenant calls, signed event delivery (`Stripe-Signature` HMAC), and the dedicated search endpoint with its `field:value` query syntax. Operational surface around the resource API where get-it-wrong incidents are visible to integrators on day one.
