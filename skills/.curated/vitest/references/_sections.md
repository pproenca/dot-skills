# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Async Patterns (async)

**Impact:** CRITICAL
**Description:** Race conditions, unhandled promises, and improper async/await handling cause false positives, false negatives, and flaky tests that erode confidence in the test suite.

## 2. Test Setup & Isolation (setup)

**Impact:** CRITICAL
**Description:** Shared state, missing cleanup, and improper beforeEach/afterEach patterns cause cascading failures where one test pollutes the environment for subsequent tests.

## 3. Mocking Patterns (mock)

**Impact:** HIGH
**Description:** Incorrect vi.mock/vi.spyOn usage, missing mock restoration, and over-mocking lead to brittle tests that pass when they should fail or test mocks instead of real behavior.

## 4. Performance (perf)

**Impact:** HIGH
**Description:** Test isolation overhead, pool selection, parallelization settings, and environment choices affect CI/CD execution time by 2-10×, directly impacting developer feedback loops.

## 5. Snapshot Testing (snap)

**Impact:** MEDIUM
**Description:** Snapshot sprawl, poor snapshot hygiene, and unstable serialization reduce test maintainability and lead to blindly updated snapshots that mask real bugs.

## 6. Environment (env)

**Impact:** MEDIUM
**Description:** DOM environment selection (jsdom vs happy-dom), browser API availability, and environment leakage affect test reliability and execution speed.

## 7. Assertions (assert)

**Impact:** LOW-MEDIUM
**Description:** Weak assertions, missing edge cases, and improper matcher selection reduce bug detection capability and produce tests that pass despite incorrect behavior.

## 8. Test Organization (org)

**Impact:** LOW
**Description:** File structure, naming conventions, describe block nesting, and test grouping patterns affect long-term maintainability and test discoverability.
