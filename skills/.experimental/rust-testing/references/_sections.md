# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Test Architecture (arch)

**Impact:** CRITICAL
**Description:** Test file organization and structure determine maintainability. Sibling test files, proper imports, and isolation patterns prevent flaky tests and merge conflicts.

## 2. Assertions (assert)

**Impact:** CRITICAL
**Description:** Assertion quality determines how quickly failures are diagnosed. Whole-object comparison with pretty_assertions catches regressions that field-by-field checks miss.

## 3. Mock Servers (mock)

**Impact:** HIGH
**Description:** HTTP mock patterns (wiremock, ResponseMock, SSE builders) enable reliable integration testing without network dependencies.

## 4. Test Data (data)

**Impact:** HIGH
**Description:** Builder patterns and factory functions for test data construction ensure consistency and reduce test maintenance burden.

## 5. Event Testing (event)

**Impact:** MEDIUM-HIGH
**Description:** Event-driven test patterns (wait_for_event, submit/assert cycles) are essential for testing the async agent protocol.

## 6. Determinism (det)

**Impact:** MEDIUM
**Description:** Deterministic tests eliminate flaky failures. Fixed seeds, BTreeMap ordering, and environment isolation prevent intermittent CI breakages.

## 7. Snapshot Testing (snap)

**Impact:** MEDIUM
**Description:** Insta snapshot tests capture UI rendering output and make visual changes reviewable in PRs.

## 8. Integration Tests (integ)

**Impact:** LOW-MEDIUM
**Description:** Integration test infrastructure (core_test_support, Bazel-compatible paths, scoped execution) enables reliable end-to-end testing.
