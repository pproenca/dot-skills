# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. OpenAPI Specification Quality (spec)

**Impact:** CRITICAL
**Description:** Poor specification quality cascades into broken types, missing models, and runtime errors. Fixing upstream prevents downstream pain.

## 2. Configuration Architecture (orvalcfg)

**Impact:** CRITICAL
**Description:** Wrong mode, client, or structure choices multiply into bundle bloat, poor developer experience, and maintenance nightmares.

## 3. Output Structure & Organization (output)

**Impact:** HIGH
**Description:** File organization directly affects tree-shaking effectiveness, import ergonomics, and long-term maintainability.

## 4. Custom Client & Mutators (mutator)

**Impact:** HIGH
**Description:** HTTP client setup affects authentication, error handling, request/response transformation, and cross-cutting concerns.

## 5. Query Library Integration (oquery)

**Impact:** MEDIUM-HIGH
**Description:** React Query, SWR, and Vue Query hook patterns affect caching behavior, refetching strategies, and UI state management.

## 6. Type Safety & Validation (types)

**Impact:** MEDIUM
**Description:** Zod integration, strict typing, and runtime validation patterns ensure data integrity at API boundaries.

## 7. Mock Generation & Testing (mock)

**Impact:** MEDIUM
**Description:** MSW setup, Faker configuration, and testing patterns enable reliable frontend development without backend dependencies.

## 8. Advanced Patterns (adv)

**Impact:** LOW
**Description:** Transformers, operation overrides, and edge case handling for complex integration scenarios.
