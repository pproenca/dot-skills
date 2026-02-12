# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Resource Modeling (res)

**Impact:** CRITICAL
**Description:** Wrong resource design cascades into every other category. Noun-based URIs, plural collections, and max 2 nesting levels form the foundation that HTTP methods, links, and caching all depend on.

## 2. HTTP Method Semantics (http)

**Impact:** CRITICAL
**Description:** GET must be safe, PUT must be idempotent, POST creates — correct verb usage is what separates Richardson Level 2 from the Swamp of POX and enables caching, retries, and intermediary support.

## 3. Hypermedia & Link Relations (link)

**Impact:** CRITICAL
**Description:** The crown jewel of REST: `_links` with standard `rel` types make APIs self-documenting and evolvable. Without hypermedia controls, clients hardcode URIs and servers cannot evolve independently.

## 4. Status Codes & Response Headers (status)

**Impact:** HIGH
**Description:** 201+Location for creates, 202 for async, 409 for conflicts — correct status codes enable client automation, caching, retry logic, and proper intermediary behavior.

## 5. Content Negotiation & Media Types (media)

**Impact:** HIGH
**Description:** Accept/Content-Type handling, HAL vs JSON:API, and custom vendor media types are the mechanism that enables HATEOAS and allows servers to serve multiple representations from a single URI.

## 6. Collection Patterns (coll)

**Impact:** MEDIUM-HIGH
**Description:** Cursor-based pagination with Link headers, filtering, sorting, and field selection make collections navigable hypermedia resources instead of unbounded data dumps.

## 7. Error Semantics (err)

**Impact:** MEDIUM
**Description:** Errors are resources too. Problem Details (RFC 9457) with machine-readable types, structured validation errors, and error links enable client automation instead of string parsing.

## 8. Caching & Conditional Requests (cache)

**Impact:** MEDIUM
**Description:** ETags, stale?/fresh_when, Cache-Control, and If-None-Match are HTTP's built-in caching — but they only work when resources have proper URIs, methods, and status codes.

## 9. API Evolution (evolve)

**Impact:** LOW-MEDIUM
**Description:** HATEOAS makes URL versioning unnecessary. Additive changes, deprecation headers, and media type versioning allow APIs to evolve without breaking existing clients.
