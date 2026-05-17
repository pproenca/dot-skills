# API Design

**Version 0.1.0**  
Stripe-Inspired  
May 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive API design guide distilled from the Stripe API — the industry's most-copied reference for JSON HTTP APIs. Contains 52 rules across 8 categories, prioritised by design-propagation impact from critical (resource modeling, URL structure) to medium-high (naming, operational surface). Each rule includes a quantified impact, the reason it matters, incorrect-vs-correct code examples, and links to canonical sources. Suitable as the source of truth for an automated API design inspector that emits structured findings (Critical / Warning / Suggestion / Positive) and cites a specific rule per finding.

---

## Table of Contents

1. [Resource Modeling & Identifiers](references/_sections.md#1-resource-modeling-&-identifiers) — **CRITICAL**
   - 1.1 [Colocate a `currency` Field; Never Bake Currency into Field Names](references/resource-currency-field-not-name.md) — CRITICAL (prevents multi-currency support becoming a breaking schema change)
   - 1.2 [Include a Read-Only `object` Discriminator on Every Resource](references/resource-object-discriminator.md) — CRITICAL (enables polymorphic deserialisation and self-describing responses)
   - 1.3 [Represent Birth Dates as `{day, month, year}` Hashes](references/resource-birthdate-hash.md) — CRITICAL (eliminates locale-string parsing ambiguity for collected dates)
   - 1.4 [Treat IDs as Opaque Strings up to 255 Characters](references/resource-opaque-ids.md) — CRITICAL (preserves freedom to change ID format without a version bump)
   - 1.5 [Use `_decimal` String Suffix for Precise Decimals That Can't Be Integers](references/resource-decimal-suffix-strings.md) — HIGH (preserves exact precision for sub-minor-unit values like FX rates and tax rates)
   - 1.6 [Use Integer Minor Units for Money, Never Floats](references/resource-integer-minor-units.md) — CRITICAL (prevents floating-point precision errors in monetary calculations)
   - 1.7 [Use ISO 8601 Date Strings for Date-Only Values](references/resource-iso-date-only.md) — CRITICAL (prevents off-by-day errors from timezone-shifted timestamps)
   - 1.8 [Use Prefixed String IDs for Every Resource](references/resource-prefixed-string-ids.md) — CRITICAL (prevents type confusion in logs, support, and codegen)
   - 1.9 [Use Unix Seconds (Integer) for All Datetimes](references/resource-unix-seconds-timestamps.md) — CRITICAL (prevents milliseconds/seconds confusion that silently produces wrong times)
2. [URL Structure & HTTP Semantics](references/_sections.md#2-url-structure-&-http-semantics) — **CRITICAL**
   - 2.1 [Express Non-CRUD Actions as Imperative Sub-Paths](references/url-action-verbs-as-subpaths.md) — CRITICAL (prevents overloaded update endpoints and ambiguous idempotency scope)
   - 2.2 [One Object Per Request — No Bulk Endpoints](references/url-no-bulk-endpoints.md) — HIGH (prevents partial-success ambiguity and broken idempotency scope)
   - 2.3 [Pluralize Collection URLs; Singularize Object Types](references/url-plural-collections.md) — CRITICAL (prevents inconsistent endpoints and hand-written SDK glue per resource)
   - 2.4 [Use a Dedicated `/search` Endpoint for Complex Queries](references/url-dedicated-search-endpoint.md) — MEDIUM-HIGH (prevents eventual-consistency leak into strongly-consistent list endpoints)
   - 2.5 [Use POST for Updates (Not PUT or PATCH)](references/url-post-for-updates.md) — CRITICAL (prevents PUT/PATCH replacement footguns and proxy-layer dropping)
   - 2.6 [Version in URL Path and `Stripe-Version` Header](references/url-version-in-path-and-header.md) — HIGH (prevents path-version forks on every backwards-incompatible change)
3. [Request & Response Format](references/_sections.md#3-request-&-response-format) — **HIGH**
   - 3.1 [Accept Form-Encoded Requests, Always Return JSON](references/format-form-encoded-requests.md) — HIGH (prevents JSON serialisation bugs in client code and makes curl trivial)
   - 3.2 [Allow Dot-Notation for Nested Expansion (Max Depth 4)](references/format-dot-notation-expansion.md) — MEDIUM-HIGH (prevents N+1 round trips for chained relationship traversal)
   - 3.3 [Expand Related Objects with `expand[]` in One Round Trip](references/format-expand-parameter.md) — MEDIUM-HIGH (prevents N+1 round trips when consumers need related resources)
   - 3.4 [Paginate by Cursor (`starting_after`/`ending_before`), Not by Offset](references/format-cursor-pagination.md) — HIGH (prevents skipped and duplicated items when the dataset changes mid-iteration)
   - 3.5 [Return Lists in a `{object, url, has_more, data}` Envelope](references/format-list-envelope.md) — HIGH (prevents inconsistent list shapes across endpoints and enables generic SDK iterators)
   - 3.6 [Use `has_more` Boolean; Never Return Total Counts](references/format-no-total-counts.md) — HIGH (prevents slow full-table scans on every paginated request)
   - 3.7 [Use Bracket Notation for Nested Fields in Form Bodies](references/format-bracket-notation-nesting.md) — MEDIUM-HIGH (prevents ambiguous nesting and supports arbitrary depth in form-encoded requests)
4. [Errors & Status Codes](references/_sections.md#4-errors-&-status-codes) — **HIGH**
   - 4.1 [Always Wrap Failures in a Top-Level `error` Object](references/error-top-level-object.md) — HIGH (prevents bespoke error parsing per endpoint)
   - 4.2 [Include `doc_url` Links and Request IDs on Every Error](references/error-doc-url-on-every-error.md) — MEDIUM-HIGH (prevents support round trips by giving developers direct links to docs and the failed request)
   - 4.3 [Map Error Types to HTTP Status Codes Consistently](references/error-http-status-mapping.md) — HIGH (prevents intermediaries from misrouting errors and clients from miscategorising them)
   - 4.4 [Require `message`; Make `code` Optional and Only for Programmatic Handling](references/error-message-mandatory-code-optional.md) — HIGH (prevents hardcoded code-to-text mappings in every client)
   - 4.5 [Use a Small Fixed `type` Enum, Don't Proliferate Types](references/error-four-type-enum.md) — HIGH (prevents error-type explosion that defeats generic handling)
   - 4.6 [Use Lowercase snake_case for Error Codes, Not SCREAMING_SNAKE_CASE](references/error-lowercase-snake-case-codes.md) — MEDIUM-HIGH (prevents casing inconsistency from becoming a breaking-change debt)
5. [Idempotency & Safe Retries](references/_sections.md#5-idempotency-&-safe-retries) — **HIGH**
   - 5.1 [Accept `Idempotency-Key` Header on All Mutating Requests](references/idem-key-header.md) — HIGH (prevents duplicate charges/transfers under network retries)
   - 5.2 [Keep Idempotency Keys for 24 Hours, Reap at 72](references/idem-24h-ttl.md) — MEDIUM-HIGH (prevents unbounded storage growth while covering near-term retry windows)
   - 5.3 [Return 409 When a Key Is Reused with Different Params](references/idem-fail-on-key-reuse.md) — HIGH (prevents silent execution of unintended operations under retry)
   - 5.4 [Scope Idempotency Keys per Account, Not Globally](references/idem-scoped-per-account.md) — HIGH (prevents key collisions across tenants in a multi-tenant API)
   - 5.5 [Use Recovery Points for Multi-Step Idempotent Operations](references/idem-recovery-points.md) — MEDIUM-HIGH (prevents partial-completion bugs when a multi-step operation crashes mid-execution)
6. [Versioning & Backwards Compatibility](references/_sections.md#6-versioning-&-backwards-compatibility) — **HIGH**
   - 6.1 [Define What Counts as a Backwards-Compatible Change](references/ver-additive-changes.md) — HIGH (prevents breaking changes from shipping by accident)
   - 6.2 [Document That Clients Must Tolerate Unknown Fields, Events, and Enum Values](references/ver-tolerate-unknown.md) — HIGH (prevents additive changes (the safe kind) from breaking existing clients)
   - 6.3 [Encapsulate Each Breaking Change in a Version-Change Module](references/ver-version-change-modules.md) — MEDIUM-HIGH (prevents version-conditional logic from sprawling through the codebase)
   - 6.4 [Pin Each Account to Its First-Request Version](references/ver-account-pinning.md) — HIGH (prevents existing integrators breaking when a new version ships)
   - 6.5 [Use Dated Versions (`YYYY-MM-DD`), Not v1/v2/v3](references/ver-dated-versions.md) — HIGH (prevents big-bang migrations and parallel SDK universes)
7. [Naming, Polymorphism & Metadata](references/_sections.md#7-naming,-polymorphism-&-metadata) — **MEDIUM-HIGH**
   - 7.1 [Booleans — Past-Tense Verbs and Plain Adjectives, Not `is_`/`has_` Prefixes](references/naming-boolean-past-tense.md) — LOW-MEDIUM (prevents inconsistent prefix conventions cluttering field names)
   - 7.2 [Discriminate Polymorphic Types with a `type` Field and Sibling Objects](references/naming-type-discriminator-polymorphism.md) — HIGH (prevents untagged unions that require runtime type-sniffing)
   - 7.3 [Names — Simple, Unambiguous, No Leading Digits, No Jargon](references/naming-simple-unambiguous.md) — MEDIUM (prevents naming debt that requires version bumps to fix)
   - 7.4 [Prefer Enums over Booleans for New Status/Flag Fields](references/naming-enums-over-booleans.md) — MEDIUM-HIGH (prevents needing a breaking change when a binary flag gains a third state)
   - 7.5 [Provide a `metadata` Pass-Through with Strict Limits](references/naming-metadata-pattern.md) — MEDIUM-HIGH (prevents per-customer schema requests for arbitrary tagging needs)
   - 7.6 [Use American English Spelling (`canceled`, Not `cancelled`)](references/naming-american-english.md) — MEDIUM-HIGH (prevents British/American spelling debt that requires a version bump to fix)
   - 7.7 [Use snake_case for All Wire Identifiers](references/naming-snake-case-wire-format.md) — HIGH (prevents casing inconsistency from forcing breaking renames later)
8. [Authentication, Webhooks & Search](references/_sections.md#8-authentication,-webhooks-&-search) — **MEDIUM-HIGH**
   - 8.1 [Document At-Least-Once Delivery; Handlers Must Dedupe on `event.id`](references/ops-webhook-at-least-once-handlers-idempotent.md) — HIGH (prevents double-processing under retries and parallel delivery)
   - 8.2 [Enforce HTTPS Only and Use HTTP Basic Auth with the Key as Username](references/ops-https-only-basic-auth.md) — HIGH (prevents key leakage over plaintext channels and trivialises curl usage)
   - 8.3 [Event Type Naming — `<resource>.<past_tense_action>`](references/ops-webhook-event-naming.md) — MEDIUM-HIGH (prevents inconsistent event-type strings that defeat generic routing)
   - 8.4 [Prefix API Keys with Scope and Mode (`sk_live_`, `pk_test_`, `rk_`)](references/ops-prefixed-api-keys.md) — HIGH (prevents production keys leaking into client code and enables secret-scanning)
   - 8.5 [Sign Webhook Deliveries with HMAC and a Timestamp Tolerance Window](references/ops-webhook-signature.md) — HIGH (prevents forged webhook calls and replay attacks)
   - 8.6 [Use a Dedicated `On-Behalf-Of` Header for Multi-Tenant Calls](references/ops-on-behalf-of-header.md) — MEDIUM-HIGH (prevents acting-account confusion in platforms with thousands of tenants)
   - 8.7 [Webhook Events Use a Fixed `{id, object, type, data, created}` Envelope](references/ops-webhook-event-envelope.md) — HIGH (prevents per-event-type parsers in every integrator)

---

## References

1. [https://github.com/stripe/openapi](https://github.com/stripe/openapi)
2. [https://docs.stripe.com/api](https://docs.stripe.com/api)
3. [https://docs.stripe.com/upgrades](https://docs.stripe.com/upgrades)
4. [https://docs.stripe.com/api/pagination](https://docs.stripe.com/api/pagination)
5. [https://docs.stripe.com/api/errors](https://docs.stripe.com/api/errors)
6. [https://docs.stripe.com/api/expanding_objects](https://docs.stripe.com/api/expanding_objects)
7. [https://docs.stripe.com/api/metadata](https://docs.stripe.com/api/metadata)
8. [https://docs.stripe.com/webhooks](https://docs.stripe.com/webhooks)
9. [https://docs.stripe.com/webhooks/signatures](https://docs.stripe.com/webhooks/signatures)
10. [https://docs.stripe.com/search](https://docs.stripe.com/search)
11. [https://docs.stripe.com/api/authentication](https://docs.stripe.com/api/authentication)
12. [https://stripe.com/blog/api-versioning](https://stripe.com/blog/api-versioning)
13. [https://stripe.com/blog/idempotency](https://stripe.com/blog/idempotency)
14. [https://brandur.org/idempotency-keys](https://brandur.org/idempotency-keys)
15. [https://brandur.org/api-versioning](https://brandur.org/api-versioning)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |