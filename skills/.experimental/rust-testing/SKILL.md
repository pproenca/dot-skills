---
name: rust-testing
description: Rust testing patterns for CLI applications, libraries, and frameworks. This skill should be used when writing, reviewing, or refactoring Rust tests including unit tests, integration tests, mocking, async testing, and CI integration. Triggers on tasks involving Rust testing, cargo test, mockall, proptest, tokio test, or test organization.
---

# Rust Testing Best Practices

Comprehensive testing guide for Rust applications, covering CLI testing, library testing, async patterns, and CI integration. Contains 42 rules across 8 categories, prioritized by impact to guide test design, mocking strategies, and CI optimization.

## When to Apply

Reference these guidelines when:
- Writing unit tests for Rust libraries or modules
- Creating integration tests for CLI applications
- Setting up mocking with mockall or trait-based design
- Testing async code with Tokio
- Configuring CI pipelines for Rust projects

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Test Organization | CRITICAL | `org-` |
| 2 | Mocking and Test Doubles | CRITICAL | `mock-` |
| 3 | Async Testing | HIGH | `async-` |
| 4 | Property-Based Testing | HIGH | `prop-` |
| 5 | Test Fixtures and Setup | MEDIUM | `fix-` |
| 6 | Assertions and Error Testing | MEDIUM | `assert-` |
| 7 | CI Integration | MEDIUM | `ci-` |
| 8 | Test Performance | LOW-MEDIUM | `perf-` |

## Quick Reference

### 1. Test Organization (CRITICAL)

- [`org-unit-test-modules`](references/org-unit-test-modules.md) - Use cfg(test) modules for unit tests
- [`org-integration-tests-directory`](references/org-integration-tests-directory.md) - Place integration tests in tests directory
- [`org-shared-test-utilities`](references/org-shared-test-utilities.md) - Use tests/common/mod.rs for shared utilities
- [`org-binary-crate-pattern`](references/org-binary-crate-pattern.md) - Extract logic from main.rs into lib.rs
- [`org-test-naming`](references/org-test-naming.md) - Name tests after behavior not implementation
- [`org-test-cli-with-assert-cmd`](references/org-test-cli-with-assert-cmd.md) - Use assert_cmd for CLI testing

### 2. Mocking and Test Doubles (CRITICAL)

- [`mock-trait-based-design`](references/mock-trait-based-design.md) - Design for testability with traits
- [`mock-automock-attribute`](references/mock-automock-attribute.md) - Use mockall automock for complex mocking
- [`mock-avoid-mocking-owned-types`](references/mock-avoid-mocking-owned-types.md) - Avoid mocking types you own
- [`mock-expect-call-counts`](references/mock-expect-call-counts.md) - Verify mock call counts explicitly
- [`mock-predicate-arguments`](references/mock-predicate-arguments.md) - Use predicates to verify mock arguments
- [`mock-returning-sequences`](references/mock-returning-sequences.md) - Use sequences for multiple return values
- [`mock-static-methods`](references/mock-static-methods.md) - Use mock! macro for static methods

### 3. Async Testing (HIGH)

- [`async-tokio-test-macro`](references/async-tokio-test-macro.md) - Use tokio::test for async test functions
- [`async-time-control`](references/async-time-control.md) - Use paused time for timeout testing
- [`async-mock-io`](references/async-mock-io.md) - Use tokio_test for mocking async IO
- [`async-spawn-blocking`](references/async-spawn-blocking.md) - Test spawn_blocking with multi-threaded runtime
- [`async-test-channels`](references/async-test-channels.md) - Use channels for testing async communication

### 4. Property-Based Testing (HIGH)

- [`prop-proptest-basics`](references/prop-proptest-basics.md) - Use proptest for property-based testing
- [`prop-custom-strategies`](references/prop-custom-strategies.md) - Create custom strategies for domain types
- [`prop-shrinking`](references/prop-shrinking.md) - Use shrinking to find minimal failing cases
- [`prop-invariant-testing`](references/prop-invariant-testing.md) - Test invariants instead of specific values

### 5. Test Fixtures and Setup (MEDIUM)

- [`fix-rstest-fixtures`](references/fix-rstest-fixtures.md) - Use rstest fixtures for test setup
- [`fix-rstest-parametrized`](references/fix-rstest-parametrized.md) - Use rstest case for parameterized tests
- [`fix-temp-directories`](references/fix-temp-directories.md) - Use TempDir for file system tests
- [`fix-test-context`](references/fix-test-context.md) - Use test-context for setup and teardown
- [`fix-once-cell-shared-state`](references/fix-once-cell-shared-state.md) - Use OnceCell for expensive shared setup

### 6. Assertions and Error Testing (MEDIUM)

- [`assert-specific-errors`](references/assert-specific-errors.md) - Assert specific error types not just is_err
- [`assert-should-panic`](references/assert-should-panic.md) - Use should_panic for panic testing
- [`assert-debug-display`](references/assert-debug-display.md) - Implement Debug for clear failure messages
- [`assert-custom-messages`](references/assert-custom-messages.md) - Add context to assertions with custom messages
- [`assert-floating-point`](references/assert-floating-point.md) - Use approximate comparison for floating point
- [`assert-collection-contents`](references/assert-collection-contents.md) - Assert collection contents not just length

### 7. CI Integration (MEDIUM)

- [`ci-cargo-nextest`](references/ci-cargo-nextest.md) - Use cargo-nextest for faster CI
- [`ci-caching`](references/ci-caching.md) - Cache Cargo dependencies in CI
- [`ci-test-isolation`](references/ci-test-isolation.md) - Ensure test isolation in parallel CI
- [`ci-coverage`](references/ci-coverage.md) - Generate coverage reports in CI

### 8. Test Performance (LOW-MEDIUM)

- [`perf-compile-time`](references/perf-compile-time.md) - Reduce test compilation time
- [`perf-test-filtering`](references/perf-test-filtering.md) - Filter tests for faster feedback loops
- [`perf-avoid-io-in-unit-tests`](references/perf-avoid-io-in-unit-tests.md) - Avoid real IO in unit tests
- [`perf-parallel-test-execution`](references/perf-parallel-test-execution.md) - Configure parallel test threads
- [`perf-benchmark-critical-paths`](references/perf-benchmark-critical-paths.md) - Benchmark critical paths with Criterion

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
