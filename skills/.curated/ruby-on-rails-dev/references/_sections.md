# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Database & ActiveRecord (db)

**Impact:** CRITICAL
**Description:** N+1 queries multiply latency by record count and are the #1 Rails performance killer. Proper eager loading, indexing, and query design eliminate the most costly bottleneck.

## 2. Controllers & Routing (ctrl)

**Impact:** CRITICAL
**Description:** Fat controllers cascade into untestable, unmaintainable code. RESTful design, thin actions, and strong params enforce clean request handling across every endpoint.

## 3. Security (sec)

**Impact:** HIGH
**Description:** SQL injection (CVSS 10.0), mass assignment, and IDOR are the top Rails vulnerabilities. Parameterized queries, strong params whitelisting, and scoped authorization prevent data breaches.

## 4. Models & Business Logic (model)

**Impact:** HIGH
**Description:** Misused callbacks create hidden side effects that break in production. Service objects, scopes, and explicit validations keep domain logic predictable and testable.

## 5. Caching & Performance (cache)

**Impact:** HIGH
**Description:** Fragment and Russian doll caching reduce database load by 10-100×. Counter caches and conditional GET eliminate redundant computation on every request.

## 6. Views & Frontend (view)

**Impact:** MEDIUM-HIGH
**Description:** Partial render overhead compounds with collection size. Turbo Frames and Streams enable SPA-like interactivity without JavaScript framework complexity.

## 7. API Design (api)

**Impact:** MEDIUM
**Description:** Over-fetching and missing pagination cause response bloat and client timeouts. Proper serialization and versioning keep APIs fast and forward-compatible.

## 8. Background Jobs & Async (job)

**Impact:** LOW-MEDIUM
**Description:** Non-idempotent jobs cause duplicate processing on retry. Proper job design with small payloads and error handling ensures reliable async execution.
