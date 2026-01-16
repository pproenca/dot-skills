# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Setup & Initialization (setup)

**Impact:** CRITICAL
**Description:** Worker and server configuration determines all downstream request interception; misconfiguration results in zero mocking capability and silent test failures.

## 2. Handler Architecture (handler)

**Impact:** CRITICAL
**Description:** Handler structure affects maintainability, match reliability, and reusability across environments; poor organization creates N×M complexity as endpoints grow.

## 3. Test Integration (test)

**Impact:** HIGH
**Description:** Improper test setup causes flaky tests, isolation failures, handler leakage between tests, and false positives that mask real bugs.

## 4. Response Patterns (response)

**Impact:** HIGH
**Description:** Response construction patterns affect type safety, realism, and consistency with production APIs; incorrect responses create false confidence in tests.

## 5. Request Matching (match)

**Impact:** MEDIUM-HIGH
**Description:** Predicate accuracy determines handler activation; subtle URL mismatches cause silent handler failures that are difficult to debug.

## 6. GraphQL Mocking (graphql)

**Impact:** MEDIUM
**Description:** GraphQL-specific patterns for intercepting operations, handling variables, query batching, and error simulation require dedicated approaches.

## 7. Advanced Patterns (advanced)

**Impact:** MEDIUM
**Description:** Complex scenarios including request bypass, passthrough, cookies, authentication, streaming, and WebSocket mocking for comprehensive API simulation.

## 8. Debugging & Performance (debug)

**Impact:** LOW
**Description:** Observability tools, lifecycle events, and troubleshooting patterns for diagnosing MSW configuration issues during development.
