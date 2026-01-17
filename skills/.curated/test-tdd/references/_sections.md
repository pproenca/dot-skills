# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Red-Green-Refactor Cycle (cycle)

**Impact:** CRITICAL
**Description:** The core TDD loop is the foundation of test-driven development. Breaking the cycle leads to untested code, design debt, and lost confidence in the test suite.

## 2. Test Design Principles (design)

**Impact:** CRITICAL
**Description:** Well-designed tests are maintainable, readable, and catch real bugs. Poor test design creates brittle, hard-to-maintain tests that provide false confidence.

## 3. Test Isolation & Dependencies (isolate)

**Impact:** HIGH
**Description:** Isolated tests run fast, are deterministic, and pinpoint failures precisely. Coupled tests create flaky suites that erode developer trust.

## 4. Test Data Management (data)

**Impact:** HIGH
**Description:** Proper test data setup prevents mystery guests, reduces coupling between tests, and keeps tests focused on the behavior being verified.

## 5. Assertions & Verification (assert)

**Impact:** MEDIUM
**Description:** Clear, specific assertions catch bugs and document expected behavior. Weak or missing assertions let bugs slip through undetected.

## 6. Test Organization & Structure (org)

**Impact:** MEDIUM
**Description:** Well-organized test suites are maintainable and navigable. Poor organization hides tests, causes duplication, and increases maintenance burden.

## 7. Test Performance & Reliability (perf)

**Impact:** MEDIUM
**Description:** Fast, reliable tests encourage frequent execution. Slow or flaky tests get ignored, reducing the value of the entire test suite.

## 8. Test Pyramid & Strategy (strat)

**Impact:** LOW
**Description:** Strategic test distribution across unit, integration, and E2E layers optimizes coverage while minimizing maintenance cost and execution time.
