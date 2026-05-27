---
name: stripe-inspired-api-design-rules
description: Use this skill whenever designing, reviewing, or refactoring a JSON HTTP API — covers resource modeling, identifier schemes, URL structure, request/response wire format, pagination, errors, idempotency, versioning, naming, webhooks, and authentication. Triggers on tasks involving OpenAPI specs, API design reviews, schema decisions, endpoint shaping, error envelope design, webhook delivery, or any "is this API well-designed" question. Apply even when the user doesn't mention Stripe by name — the rules are general API-design principles distilled from the Stripe API, which is the industry's most-copied reference.
---

# Stripe-Inspired API Design Best Practices

A reference distillation of the design conventions behind Stripe's API — the most widely admired and copied JSON HTTP API in the industry. Contains 52 actionable rules across 8 categories, prioritised by how irreversibly a wrong decision cascades through every endpoint, every SDK, and every client integration. Each rule explains the WHY, shows incorrect-vs-correct code, and links to the canonical source.

## When to Apply

Reach for this skill when:

- Designing a new JSON HTTP API or a new endpoint on an existing one
- Reviewing an API design proposal, OpenAPI spec, or PR that adds/changes endpoints
- Debugging an integration where the "wrong" shape of the API is causing client bugs
- Auditing an API for naming consistency, error shape uniformity, or compatibility risks
- Producing an API design report (the kind your inspector tool emits — `Critical / Warning / Suggestion / Positive`)
- Picking between two designs and looking for an authoritative source to back the choice
- Onboarding to API design — these are the canonical patterns to internalise first

The rules are general — they apply to any JSON HTTP API, not just APIs imitating Stripe. Triggers include "API design", "OpenAPI", "endpoint", "schema", "webhook", "idempotency", "pagination", "API versioning", and reviews of YAML/JSON spec files.

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Resource Modeling & Identifiers | CRITICAL | `resource-` |
| 2 | URL Structure & HTTP Semantics | CRITICAL | `url-` |
| 3 | Request & Response Format | HIGH | `format-` |
| 4 | Errors & Status Codes | HIGH | `error-` |
| 5 | Idempotency & Safe Retries | HIGH | `idem-` |
| 6 | Versioning & Backwards Compatibility | HIGH | `ver-` |
| 7 | Naming, Polymorphism & Metadata | MEDIUM-HIGH | `naming-` |
| 8 | Authentication, Webhooks & Search | MEDIUM-HIGH | `ops-` |

Earlier categories cascade harder: a wrong choice in resource modeling (numeric IDs, no `object` discriminator) propagates to every endpoint forever; a wrong choice in webhook event naming is a single category to fix.

## Quick Reference

### 1. Resource Modeling & Identifiers (CRITICAL)

- [`resource-prefixed-string-ids`](references/resource-prefixed-string-ids.md) — Use Prefixed String IDs for Every Resource
- [`resource-object-discriminator`](references/resource-object-discriminator.md) — Include a Read-Only `object` Discriminator on Every Resource
- [`resource-opaque-ids`](references/resource-opaque-ids.md) — Treat IDs as Opaque Strings up to 255 Characters
- [`resource-unix-seconds-timestamps`](references/resource-unix-seconds-timestamps.md) — Use Unix Seconds (Integer) for All Datetimes
- [`resource-iso-date-only`](references/resource-iso-date-only.md) — Use ISO 8601 Date Strings for Date-Only Values
- [`resource-birthdate-hash`](references/resource-birthdate-hash.md) — Represent Birth Dates as `{day, month, year}` Hashes
- [`resource-integer-minor-units`](references/resource-integer-minor-units.md) — Use Integer Minor Units for Money, Never Floats
- [`resource-currency-field-not-name`](references/resource-currency-field-not-name.md) — Colocate a `currency` Field; Never Bake Currency into Field Names
- [`resource-decimal-suffix-strings`](references/resource-decimal-suffix-strings.md) — Use `_decimal` String Suffix for Precise Decimals That Can't Be Integers

### 2. URL Structure & HTTP Semantics (CRITICAL)

- [`url-plural-collections`](references/url-plural-collections.md) — Pluralize Collection URLs; Singularize Object Types
- [`url-post-for-updates`](references/url-post-for-updates.md) — Use POST for Updates (Not PUT or PATCH)
- [`url-action-verbs-as-subpaths`](references/url-action-verbs-as-subpaths.md) — Express Non-CRUD Actions as Imperative Sub-Paths
- [`url-no-bulk-endpoints`](references/url-no-bulk-endpoints.md) — One Object Per Request — No Bulk Endpoints
- [`url-version-in-path-and-header`](references/url-version-in-path-and-header.md) — Version in URL Path and `Stripe-Version` Header
- [`url-dedicated-search-endpoint`](references/url-dedicated-search-endpoint.md) — Use a Dedicated `/search` Endpoint for Complex Queries

### 3. Request & Response Format (HIGH)

- [`format-form-encoded-requests`](references/format-form-encoded-requests.md) — Accept Form-Encoded Requests, Always Return JSON
- [`format-bracket-notation-nesting`](references/format-bracket-notation-nesting.md) — Use Bracket Notation for Nested Fields in Form Bodies
- [`format-list-envelope`](references/format-list-envelope.md) — Return Lists in a `{object, url, has_more, data}` Envelope
- [`format-cursor-pagination`](references/format-cursor-pagination.md) — Paginate by Cursor (`starting_after`/`ending_before`), Not by Offset
- [`format-no-total-counts`](references/format-no-total-counts.md) — Use `has_more` Boolean; Never Return Total Counts
- [`format-expand-parameter`](references/format-expand-parameter.md) — Expand Related Objects with `expand[]` in One Round Trip
- [`format-dot-notation-expansion`](references/format-dot-notation-expansion.md) — Allow Dot-Notation for Nested Expansion (Max Depth 4)

### 4. Errors & Status Codes (HIGH)

- [`error-top-level-object`](references/error-top-level-object.md) — Always Wrap Failures in a Top-Level `error` Object
- [`error-four-type-enum`](references/error-four-type-enum.md) — Use a Small Fixed `type` Enum, Don't Proliferate Types
- [`error-message-mandatory-code-optional`](references/error-message-mandatory-code-optional.md) — Require `message`; Make `code` Optional and Only for Programmatic Handling
- [`error-lowercase-snake-case-codes`](references/error-lowercase-snake-case-codes.md) — Use Lowercase snake_case for Error Codes, Not SCREAMING_SNAKE_CASE
- [`error-http-status-mapping`](references/error-http-status-mapping.md) — Map Error Types to HTTP Status Codes Consistently
- [`error-doc-url-on-every-error`](references/error-doc-url-on-every-error.md) — Include `doc_url` Links and Request IDs on Every Error

### 5. Idempotency & Safe Retries (HIGH)

- [`idem-key-header`](references/idem-key-header.md) — Accept `Idempotency-Key` Header on All Mutating Requests
- [`idem-scoped-per-account`](references/idem-scoped-per-account.md) — Scope Idempotency Keys per Account, Not Globally
- [`idem-24h-ttl`](references/idem-24h-ttl.md) — Keep Idempotency Keys for 24 Hours, Reap at 72
- [`idem-fail-on-key-reuse`](references/idem-fail-on-key-reuse.md) — Return 409 When a Key Is Reused with Different Params
- [`idem-recovery-points`](references/idem-recovery-points.md) — Use Recovery Points for Multi-Step Idempotent Operations

### 6. Versioning & Backwards Compatibility (HIGH)

- [`ver-dated-versions`](references/ver-dated-versions.md) — Use Dated Versions (`YYYY-MM-DD`), Not v1/v2/v3
- [`ver-account-pinning`](references/ver-account-pinning.md) — Pin Each Account to Its First-Request Version
- [`ver-additive-changes`](references/ver-additive-changes.md) — Define What Counts as a Backwards-Compatible Change
- [`ver-version-change-modules`](references/ver-version-change-modules.md) — Encapsulate Each Breaking Change in a Version-Change Module
- [`ver-tolerate-unknown`](references/ver-tolerate-unknown.md) — Document That Clients Must Tolerate Unknown Fields, Events, and Enum Values

### 7. Naming, Polymorphism & Metadata (MEDIUM-HIGH)

- [`naming-snake-case-wire-format`](references/naming-snake-case-wire-format.md) — Use snake_case for All Wire Identifiers
- [`naming-american-english`](references/naming-american-english.md) — Use American English Spelling (`canceled`, Not `cancelled`)
- [`naming-simple-unambiguous`](references/naming-simple-unambiguous.md) — Names — Simple, Unambiguous, No Leading Digits, No Jargon
- [`naming-type-discriminator-polymorphism`](references/naming-type-discriminator-polymorphism.md) — Discriminate Polymorphic Types with a `type` Field and Sibling Objects
- [`naming-metadata-pattern`](references/naming-metadata-pattern.md) — Provide a `metadata` Pass-Through with Strict Limits
- [`naming-boolean-past-tense`](references/naming-boolean-past-tense.md) — Booleans — Past-Tense Verbs and Plain Adjectives, Not `is_`/`has_` Prefixes
- [`naming-enums-over-booleans`](references/naming-enums-over-booleans.md) — Prefer Enums over Booleans for New Status/Flag Fields

### 8. Authentication, Webhooks & Search (MEDIUM-HIGH)

- [`ops-prefixed-api-keys`](references/ops-prefixed-api-keys.md) — Prefix API Keys with Scope and Mode (`sk_live_`, `pk_test_`, `rk_`)
- [`ops-https-only-basic-auth`](references/ops-https-only-basic-auth.md) — Enforce HTTPS Only and Use HTTP Basic Auth with the Key as Username
- [`ops-on-behalf-of-header`](references/ops-on-behalf-of-header.md) — Use a Dedicated `On-Behalf-Of` Header for Multi-Tenant Calls
- [`ops-webhook-event-envelope`](references/ops-webhook-event-envelope.md) — Webhook Events Use a Fixed `{id, object, type, data, created}` Envelope
- [`ops-webhook-event-naming`](references/ops-webhook-event-naming.md) — Event Type Naming — `<resource>.<past_tense_action>`
- [`ops-webhook-signature`](references/ops-webhook-signature.md) — Sign Webhook Deliveries with HMAC and a Timestamp Tolerance Window
- [`ops-webhook-at-least-once-handlers-idempotent`](references/ops-webhook-at-least-once-handlers-idempotent.md) — Document At-Least-Once Delivery; Handlers Must Dedupe on `event.id`

## How to Use

For a focused question ("should this field be a boolean or an enum?"), jump directly to the relevant rule (`naming-enums-over-booleans`) — each rule is self-contained with the WHY, code examples, and the canonical source.

For a full API review or audit, work through the categories top-to-bottom. The order matches Stripe's own design priority: get resource modeling and URL structure right first; format, errors, idempotency, and versioning are the next layer; naming and operational surface come last because they're the easiest to evolve.

For producing a structured findings report (the kind an inspector tool emits), cite rules by their slug — `resource-unix-seconds-timestamps`, `format-no-total-counts` — so each finding traces back to a specific, defensible source.

Read [section definitions](references/_sections.md) for the cascade-impact rationale behind the category ordering, or [the rule template](assets/templates/_template.md) when adding a new rule.

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering by design-propagation impact |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for authoring new rules |
| [metadata.json](metadata.json) | Version and reference URLs |
| [gotchas.md](gotchas.md) | Failure points discovered when applying the rules |
