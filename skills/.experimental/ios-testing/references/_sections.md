# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Test Architecture & Testability (arch)

**Impact:** CRITICAL
**Description:** If production code is not designed for testability, no testing technique can compensate. Protocol-based dependency injection, testable module boundaries, and proper test target organization are the foundation every other category depends on.

## 2. Unit Testing Fundamentals (unit)

**Impact:** CRITICAL
**Description:** Unit tests provide the fastest feedback loop and catch the highest density of bugs per line of test code. Mastering Swift Testing and XCTest assertion patterns, parameterized tests, and structured test naming determines the entire suite's signal-to-noise ratio.

## 3. Test Doubles & Isolation (mock)

**Impact:** HIGH
**Description:** Incorrect use of mocks produces brittle tests that break on every refactor. Protocol-based fakes, spies, and stubs isolate the system under test while keeping tests resilient to implementation changes.

## 4. Async & Concurrency Testing (async)

**Impact:** HIGH
**Description:** Modern Swift apps are async-first. Mishandled expectations, missing MainActor isolation, and untested actor boundaries produce flaky tests and shipped race conditions.

## 5. SwiftUI Testing (swiftui)

**Impact:** MEDIUM-HIGH
**Description:** SwiftUI's declarative reactive model requires testing strategies distinct from UIKit. Testing @Observable models, environment injection, and view behavior ensures correctness without fighting the framework.

## 6. UI & Acceptance Testing (ui)

**Impact:** MEDIUM
**Description:** XCUITest validates end-to-end user journeys. The Page Object pattern, accessibility identifiers, and launch argument configuration determine whether UI tests are a reliable safety net or an unmaintainable liability.

## 7. Snapshot & Visual Testing (snap)

**Impact:** MEDIUM
**Description:** Snapshot tests catch unintended visual regressions across devices, dark mode, and dynamic type sizes with zero manual effort per assertion.

## 8. Test Reliability & CI (ci)

**Impact:** LOW-MEDIUM
**Description:** Flaky tests erode team confidence and slow delivery. Test plans, parallel execution, deterministic ordering, and coverage thresholds keep the suite green and fast at scale.
