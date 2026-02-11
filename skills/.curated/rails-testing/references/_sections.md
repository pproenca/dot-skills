# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Test Design & Structure (design)

**Impact:** CRITICAL
**Description:** Mystery guests, obscure assertions, and untraceable setup are the #1 cause of unmaintainable test suites. Four-phase structure and behavior-focused tests make every spec self-documenting and resilient to refactoring.

## 2. Test Data Management (data)

**Impact:** CRITICAL
**Description:** Fixture coupling and factory misuse create brittle, slow test suites that break on unrelated changes. Proper factory design with traits and transient attributes keeps data minimal, explicit, and fast to build.

## 3. Model Testing (model)

**Impact:** HIGH
**Description:** Models are the foundation of the test pyramid and the cheapest specs to run. Testing validations, associations, scopes, and callbacks at the unit level catches 80% of bugs before they reach integration.

## 4. Request & Controller Testing (request)

**Impact:** HIGH
**Description:** Request specs exercise the full HTTP stack—routing, middleware, params, and responses. They replaced controller specs as the Rails-recommended approach and catch integration issues that unit tests miss.

## 5. System & Acceptance Testing (system)

**Impact:** MEDIUM-HIGH
**Description:** System tests verify complete user journeys through the browser. Page objects, proper waiting strategies, and focused scenario selection prevent the flaky, slow tests that erode team confidence.

## 6. Async & Background Job Testing (async)

**Impact:** MEDIUM
**Description:** Untested jobs silently fail in production. Separating enqueue verification from execution testing with proper Sidekiq/Active Job modes ensures reliable async processing without flaky timing dependencies.

## 7. Test Performance & Reliability (perf)

**Impact:** MEDIUM
**Description:** A 30-minute test suite kills developer feedback loops. Parallel execution, database strategy optimization, and flaky test quarantine restore sub-5-minute CI runs.

## 8. Test Organization & Maintenance (org)

**Impact:** LOW-MEDIUM
**Description:** Over-abstracted shared examples and deeply nested contexts trade readability for DRY purity. Self-contained specs with focused helpers scale better than clever abstractions.
