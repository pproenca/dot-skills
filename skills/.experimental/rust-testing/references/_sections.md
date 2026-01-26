# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Test Organization (org)

**Impact:** CRITICAL
**Description:** Proper separation of unit and integration tests determines maintainability and test isolation. Poor organization creates test pollution, slow CI, and debugging nightmares.

## 2. Mocking and Test Doubles (mock)

**Impact:** CRITICAL
**Description:** Incorrect mocking leads to brittle tests that break on refactors. Trait-based design and proper mock boundaries enable testable, maintainable code.

## 3. Async Testing (async)

**Impact:** HIGH
**Description:** Async test misconfiguration causes flaky tests, deadlocks, and resource leaks. Proper Tokio runtime setup and time control are essential for reliable async tests.

## 4. Property-Based Testing (prop)

**Impact:** HIGH
**Description:** Manual test cases miss edge cases that cause production bugs. Property testing with proptest finds bugs that hand-written tests consistently miss.

## 5. Test Fixtures and Setup (fix)

**Impact:** MEDIUM
**Description:** Manual setup and teardown causes code duplication and test pollution. Proper fixtures with rstest improve maintainability and test isolation.

## 6. Assertions and Error Testing (assert)

**Impact:** MEDIUM
**Description:** Weak assertions pass when they should fail. Strong assertions with proper error matching catch real bugs and provide clear failure messages.

## 7. CI Integration (ci)

**Impact:** MEDIUM
**Description:** Improper CI configuration leads to slow pipelines, flaky tests, and missed bugs. Parallel execution and caching strategies keep feedback loops fast.

## 8. Test Performance (perf)

**Impact:** LOW-MEDIUM
**Description:** Slow tests discourage running them frequently. Compilation and execution optimizations keep feedback loops fast and developers productive.
