---
name: restful-hateoas
description: RESTful API design guidelines following the Richardson Maturity Model through to Level 3 (HATEOAS) for Ruby on Rails. This skill should be used when designing, building, reviewing, or refactoring REST APIs to ensure proper resource modeling, HTTP method semantics, hypermedia controls, content negotiation, and API evolvability. Triggers on tasks involving API controllers, serializers, routing, link relations, pagination, error handling, or HTTP caching in Rails.
---

# Community RESTful HATEOAS Best Practices

Comprehensive guide to building REST APIs that reach the Glory of REST (Richardson Maturity Level 3) in Ruby on Rails. Contains 47 rules across 9 categories, ordered by the request/response lifecycle — from resource URI design through hypermedia link relations to API evolution.

## When to Apply

Reference these guidelines when:
- Designing new REST API endpoints and resource URIs
- Adding hypermedia controls (_links, affordances) to API responses
- Implementing content negotiation with HAL, JSON:API, or vendor media types
- Building paginated, filterable, sortable collection endpoints
- Reviewing APIs for proper HTTP method semantics and status codes
- Evolving APIs without breaking existing clients

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Resource Modeling | CRITICAL | `res-` |
| 2 | HTTP Method Semantics | CRITICAL | `http-` |
| 3 | Hypermedia & Link Relations | CRITICAL | `link-` |
| 4 | Status Codes & Response Headers | HIGH | `status-` |
| 5 | Content Negotiation & Media Types | HIGH | `media-` |
| 6 | Collection Patterns | MEDIUM-HIGH | `coll-` |
| 7 | Error Semantics | MEDIUM | `err-` |
| 8 | Caching & Conditional Requests | MEDIUM | `cache-` |
| 9 | API Evolution | LOW-MEDIUM | `evolve-` |

## Quick Reference

### 1. Resource Modeling (CRITICAL)

- [`res-noun-based-uris`](references/res-noun-based-uris.md) - URIs must be nouns, not verbs
- [`res-plural-collection-uris`](references/res-plural-collection-uris.md) - Always use plural nouns for collections
- [`res-limit-nesting-depth`](references/res-limit-nesting-depth.md) - Limit nested resources to max 2 levels
- [`res-model-business-entities`](references/res-model-business-entities.md) - Model business entities, not database tables
- [`res-use-consistent-identifiers`](references/res-use-consistent-identifiers.md) - Use opaque identifiers, never auto-increment IDs
- [`res-sub-resources-for-relationships`](references/res-sub-resources-for-relationships.md) - Express relationships as sub-resources

### 2. HTTP Method Semantics (CRITICAL)

- [`http-get-must-be-safe`](references/http-get-must-be-safe.md) - Keep GET requests free of side effects
- [`http-post-for-creation`](references/http-post-for-creation.md) - Return 201 Created with Location header from POST
- [`http-put-for-full-replacement`](references/http-put-for-full-replacement.md) - Use PUT only for full resource replacement
- [`http-patch-for-partial-updates`](references/http-patch-for-partial-updates.md) - PATCH for partial updates with merge semantics
- [`http-delete-is-idempotent`](references/http-delete-is-idempotent.md) - Ensure DELETE is idempotent
- [`http-head-for-metadata`](references/http-head-for-metadata.md) - Use HEAD for metadata without body transfer
- [`http-idempotency-key`](references/http-idempotency-key.md) - Use idempotency keys for safe POST retries

### 3. Hypermedia & Link Relations (CRITICAL)

- [`link-self-link-every-resource`](references/link-self-link-every-resource.md) - Include a self link in every resource
- [`link-related-resource-links`](references/link-related-resource-links.md) - Link to related resources instead of foreign keys
- [`link-action-affordances`](references/link-action-affordances.md) - Expose available actions as conditional links
- [`link-standard-relation-types`](references/link-standard-relation-types.md) - Use IANA-registered link relation types
- [`link-entry-point`](references/link-entry-point.md) - Provide a root API entry point
- [`link-pagination-links`](references/link-pagination-links.md) - Use hypermedia links for pagination
- [`link-embedded-vs-linked`](references/link-embedded-vs-linked.md) - Choose between embedding and linking

### 4. Status Codes & Response Headers (HIGH)

- [`status-201-with-location`](references/status-201-with-location.md) - Return 201 Created with Location header
- [`status-204-for-no-content`](references/status-204-for-no-content.md) - Return 204 No Content for empty responses
- [`status-409-for-conflicts`](references/status-409-for-conflicts.md) - Return 409 Conflict for state conflicts
- [`status-202-for-async`](references/status-202-for-async.md) - Return 202 Accepted for async operations
- [`status-allow-header-on-405`](references/status-allow-header-on-405.md) - Return 405 with Allow header for wrong methods
- [`status-rate-limit-headers`](references/status-rate-limit-headers.md) - Include rate limit headers in API responses

### 5. Content Negotiation & Media Types (HIGH)

- [`media-accept-header-negotiation`](references/media-accept-header-negotiation.md) - Respect the Accept header for content negotiation
- [`media-content-type-in-responses`](references/media-content-type-in-responses.md) - Set the correct Content-Type in every response
- [`media-vendor-media-types`](references/media-vendor-media-types.md) - Use vendor media types for API versioning
- [`media-406-for-unsupported-types`](references/media-406-for-unsupported-types.md) - Return 406 for unsupported media types

### 6. Collection Patterns (MEDIUM-HIGH)

- [`coll-cursor-pagination`](references/coll-cursor-pagination.md) - Use cursor-based pagination instead of offset
- [`coll-link-header-pagination`](references/coll-link-header-pagination.md) - Include pagination links in body and Link header
- [`coll-filtering-via-query-params`](references/coll-filtering-via-query-params.md) - Support filtering via typed query parameters
- [`coll-sorting-convention`](references/coll-sorting-convention.md) - Support sorting with a standardized sort parameter
- [`coll-field-selection`](references/coll-field-selection.md) - Support sparse fieldsets via fields parameter

### 7. Error Semantics (MEDIUM)

- [`err-problem-details`](references/err-problem-details.md) - Use Problem Details (RFC 9457) for errors
- [`err-validation-errors`](references/err-validation-errors.md) - Return structured validation errors
- [`err-error-links`](references/err-error-links.md) - Include recovery links in error responses
- [`err-machine-readable-codes`](references/err-machine-readable-codes.md) - Use machine-readable error codes
- [`err-auth-error-codes`](references/err-auth-error-codes.md) - Distinguish 401 Unauthorized from 403 Forbidden

### 8. Caching & Conditional Requests (MEDIUM)

- [`cache-etag-conditional-get`](references/cache-etag-conditional-get.md) - Use ETags with stale? for conditional GET
- [`cache-last-modified`](references/cache-last-modified.md) - Set Last-Modified for time-based validation
- [`cache-cache-control-headers`](references/cache-cache-control-headers.md) - Set explicit Cache-Control headers
- [`cache-vary-header`](references/cache-vary-header.md) - Include Vary header for content-dependent caching

### 9. API Evolution (LOW-MEDIUM)

- [`evolve-additive-changes-only`](references/evolve-additive-changes-only.md) - Make only additive changes to responses
- [`evolve-deprecation-headers`](references/evolve-deprecation-headers.md) - Use Deprecation and Sunset headers
- [`evolve-hateoas-reduces-versioning`](references/evolve-hateoas-reduces-versioning.md) - Leverage HATEOAS to eliminate URL versioning

## How to Use

Read individual reference files for detailed explanations and code examples:

- [Section definitions](references/_sections.md) - Category structure and impact levels
- [Rule template](assets/templates/_template.md) - Template for adding new rules

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and reference information |
