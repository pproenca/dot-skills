---
name: ios-testing-best-practices
description: iOS testing best practices for Swift and SwiftUI applications at principal engineer level. This skill should be used when writing, reviewing, or refactoring test code for iOS apps. Triggers on tasks involving unit tests, UI tests, XCTest, Swift Testing, mocking, snapshot testing, test architecture, dependency injection for testability, async testing, or CI test infrastructure.
---

# iOS Testing Best Practices

Comprehensive testing guide for iOS and Swift applications, written at principal engineer level. Contains 44 rules across 8 categories, prioritized by impact to guide test architecture decisions, test authoring patterns, and CI infrastructure.

## When to Apply

Reference these guidelines when:
- Writing new unit tests or UI tests for iOS apps
- Designing testable architecture with dependency injection
- Testing async/await, actors, and Combine publishers
- Setting up snapshot testing or visual regression suites
- Configuring CI pipelines, test plans, and parallel execution

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Test Architecture & Testability | CRITICAL | `arch-` |
| 2 | Unit Testing Fundamentals | CRITICAL | `unit-` |
| 3 | Test Doubles & Isolation | HIGH | `mock-` |
| 4 | Async & Concurrency Testing | HIGH | `async-` |
| 5 | SwiftUI Testing | MEDIUM-HIGH | `swiftui-` |
| 6 | UI & Acceptance Testing | MEDIUM | `ui-` |
| 7 | Snapshot & Visual Testing | MEDIUM | `snap-` |
| 8 | Test Reliability & CI | LOW-MEDIUM | `ci-` |

## Quick Reference

### 1. Test Architecture & Testability (CRITICAL)

- [`arch-protocol-dependencies`](references/arch-protocol-dependencies.md) - Depend on protocols, not concrete types
- [`arch-constructor-injection`](references/arch-constructor-injection.md) - Use constructor injection over service locators
- [`arch-test-target-separation`](references/arch-test-target-separation.md) - Separate unit and UI test targets
- [`arch-testable-import`](references/arch-testable-import.md) - Use @testable import sparingly
- [`arch-single-responsibility-tests`](references/arch-single-responsibility-tests.md) - One assertion concept per test
- [`arch-arrange-act-assert`](references/arch-arrange-act-assert.md) - Structure tests as Arrange-Act-Assert

### 2. Unit Testing Fundamentals (CRITICAL)

- [`unit-swift-testing-framework`](references/unit-swift-testing-framework.md) - Use Swift Testing over XCTest for new tests
- [`unit-parameterized-tests`](references/unit-parameterized-tests.md) - Use parameterized tests for input variations
- [`unit-descriptive-test-names`](references/unit-descriptive-test-names.md) - Name tests after the behavior they verify
- [`unit-expect-over-assert`](references/unit-expect-over-assert.md) - Use #expect and #require over XCTAssert
- [`unit-require-preconditions`](references/unit-require-preconditions.md) - Use #require for test preconditions
- [`unit-test-suites`](references/unit-test-suites.md) - Organize related tests into suites
- [`unit-test-tags`](references/unit-test-tags.md) - Use tags to categorize cross-cutting tests

### 3. Test Doubles & Isolation (HIGH)

- [`mock-protocol-based-mocks`](references/mock-protocol-based-mocks.md) - Create mocks from protocols, not subclasses
- [`mock-spy-for-verification`](references/mock-spy-for-verification.md) - Use spies to verify interactions
- [`mock-stub-return-values`](references/mock-stub-return-values.md) - Use stubs for deterministic return values
- [`mock-avoid-over-mocking`](references/mock-avoid-over-mocking.md) - Avoid mocking value types and simple logic
- [`mock-fake-for-integration`](references/mock-fake-for-integration.md) - Use in-memory fakes for integration tests
- [`mock-dependency-container`](references/mock-dependency-container.md) - Use a dependency container for test configuration

### 4. Async & Concurrency Testing (HIGH)

- [`async-await-directly`](references/async-await-directly.md) - Await async functions directly in tests
- [`async-confirmation`](references/async-confirmation.md) - Use confirmation() for callback-based APIs
- [`async-mainactor-isolation`](references/async-mainactor-isolation.md) - Test MainActor-isolated code on MainActor
- [`async-actor-testing`](references/async-actor-testing.md) - Test actor state through async interface
- [`async-task-cancellation`](references/async-task-cancellation.md) - Test task cancellation paths explicitly

### 5. SwiftUI Testing (MEDIUM-HIGH)

- [`swiftui-test-observable-models`](references/swiftui-test-observable-models.md) - Test @Observable models as plain objects
- [`swiftui-environment-injection`](references/swiftui-environment-injection.md) - Inject environment dependencies for tests
- [`swiftui-preview-as-test`](references/swiftui-preview-as-test.md) - Use previews as visual smoke tests
- [`swiftui-view-model-extraction`](references/swiftui-view-model-extraction.md) - Extract logic from views into testable models
- [`swiftui-binding-testing`](references/swiftui-binding-testing.md) - Test binding behavior with @Bindable

### 6. UI & Acceptance Testing (MEDIUM)

- [`ui-accessibility-identifiers`](references/ui-accessibility-identifiers.md) - Use accessibility identifiers for element queries
- [`ui-page-object-pattern`](references/ui-page-object-pattern.md) - Encapsulate screens in page objects
- [`ui-launch-arguments`](references/ui-launch-arguments.md) - Configure test state via launch arguments
- [`ui-wait-for-elements`](references/ui-wait-for-elements.md) - Wait for elements instead of using sleep()
- [`ui-test-user-journeys`](references/ui-test-user-journeys.md) - Test complete user journeys, not individual screens
- [`ui-reset-state-between-tests`](references/ui-reset-state-between-tests.md) - Reset app state between UI tests

### 7. Snapshot & Visual Testing (MEDIUM)

- [`snap-swift-snapshot-testing`](references/snap-swift-snapshot-testing.md) - Use swift-snapshot-testing for visual regression
- [`snap-device-matrix`](references/snap-device-matrix.md) - Snapshot across device sizes and traits
- [`snap-named-references`](references/snap-named-references.md) - Use named snapshot references for clarity
- [`snap-inline-snapshots`](references/snap-inline-snapshots.md) - Use inline snapshots for non-image assertions

### 8. Test Reliability & CI (LOW-MEDIUM)

- [`ci-test-plans`](references/ci-test-plans.md) - Use Xcode Test Plans for environment configurations
- [`ci-parallel-execution`](references/ci-parallel-execution.md) - Enable parallel test execution
- [`ci-flaky-test-quarantine`](references/ci-flaky-test-quarantine.md) - Quarantine flaky tests instead of disabling them
- [`ci-deterministic-test-data`](references/ci-deterministic-test-data.md) - Use deterministic test data over random generation
- [`ci-coverage-thresholds`](references/ci-coverage-thresholds.md) - Set coverage thresholds for critical paths

## How to Use

Read individual reference files for detailed explanations and code examples:

- [Section definitions](references/_sections.md) - Category structure and impact levels
- [Rule template](assets/templates/_template.md) - Template for adding new rules

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and reference information |
