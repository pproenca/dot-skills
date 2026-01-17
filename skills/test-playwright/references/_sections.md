# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Test Architecture (arch)

**Impact:** CRITICAL
**Description:** Test isolation and parallel execution patterns affect all subsequent tests; poor architecture creates cascading failures across the entire test suite.

## 2. Selectors & Locators (loc)

**Impact:** CRITICAL
**Description:** Unstable selectors are the #1 cause of flaky tests; using role-based and accessibility-first locators eliminates 80% of selector-related failures.

## 3. Waiting & Assertions (wait)

**Impact:** HIGH
**Description:** Auto-waiting and web-first assertions prevent timing-related failures; hard waits and manual checks are the second most common cause of flakiness.

## 4. Authentication & State (auth)

**Impact:** HIGH
**Description:** Session reuse and storage state patterns reduce test execution time by 60-80% while eliminating login-related flakiness.

## 5. Mocking & Network (mock)

**Impact:** MEDIUM-HIGH
**Description:** API mocking and network interception eliminate external dependencies, making tests deterministic and independent of backend state.

## 6. Next.js Integration (next)

**Impact:** MEDIUM
**Description:** App Router, Server Components, and hydration-specific patterns address Next.js-specific testing challenges that cause subtle failures.

## 7. Performance & Speed (perf)

**Impact:** MEDIUM
**Description:** Parallel execution, sharding, and resource optimization reduce test suite runtime from minutes to seconds.

## 8. Debugging & CI (debug)

**Impact:** LOW-MEDIUM
**Description:** Tracing, screenshots, and CI integration provide visibility into failures and enable efficient debugging workflows.
