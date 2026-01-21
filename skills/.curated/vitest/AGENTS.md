# Vitest

**Version 1.0.0**  
community  
January 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive testing best practices guide for Vitest, designed for AI agents and LLMs. Contains 44 rules across 8 categories, prioritized by impact from critical (async patterns, test isolation) to incremental (test organization). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated test writing and code review.

---

## Table of Contents

1. [Async Patterns](references/_sections.md#1-async-patterns) — **CRITICAL**
   - 1.1 [Await Async Assertions](references/async-await-assertions.md) — CRITICAL (Prevents false positives where tests pass despite failing assertions)
   - 1.2 [Await User Events to Avoid Act Warnings](references/async-act-wrapper.md) — CRITICAL (Prevents "not wrapped in act(...)" warnings and ensures UI updates complete)
   - 1.3 [Return Promises from Test Functions](references/async-return-promises.md) — CRITICAL (Prevents tests from completing before async operations finish)
   - 1.4 [Test Async Error Handling Properly](references/async-error-handling.md) — CRITICAL (Prevents tests from passing when async operations fail silently)
   - 1.5 [Use Fake Timers for Time-Dependent Code](references/async-fake-timers.md) — CRITICAL (Eliminates timer-based flaky tests and reduces test duration by 100×)
   - 1.6 [Use Test Context Expect in Concurrent Tests](references/async-concurrent-expect.md) — CRITICAL (Prevents snapshot collision and assertion cross-contamination in parallel tests)
   - 1.7 [Use vi.waitFor for Async Conditions](references/async-waitfor-polling.md) — CRITICAL (Replaces arbitrary timeouts with condition-based waiting, eliminating flaky tests)
2. [Test Setup & Isolation](references/_sections.md#2-test-setup-&-isolation) — **CRITICAL**
   - 2.1 [Avoid Shared Mutable State Between Tests](references/setup-avoid-shared-state.md) — CRITICAL (Eliminates order-dependent test failures and enables reliable parallel execution)
   - 2.2 [Clean Up State in afterEach Hooks](references/setup-beforeeach-cleanup.md) — CRITICAL (Prevents test pollution where one test's side effects cause subsequent tests to fail)
   - 2.3 [Reset Modules When Testing Module State](references/setup-reset-modules.md) — HIGH (Ensures modules with cached state are properly isolated between tests)
   - 2.4 [Restore Mocks After Each Test](references/setup-restore-mocks.md) — CRITICAL (Prevents mock leakage where mocked behavior persists into unrelated tests)
   - 2.5 [Use beforeAll for Expensive One-Time Setup](references/setup-beforeall-expensive.md) — HIGH (Reduces test suite time by 50-90% for tests with expensive setup)
   - 2.6 [Use Test Factories for Complex Test Data](references/setup-test-factories.md) — MEDIUM (Reduces test setup boilerplate by 60% and improves test readability)
3. [Mocking Patterns](references/_sections.md#3-mocking-patterns) — **HIGH**
   - 3.1 [Avoid Over-Mocking](references/mock-avoid-overmocking.md) — HIGH (Prevents tests that pass despite broken code by testing mocks instead of behavior)
   - 3.2 [Choose vi.spyOn vs vi.mock Appropriately](references/mock-spyon-vs-mock.md) — HIGH (Prevents over-mocking and ensures tests exercise real code paths)
   - 3.3 [Clear Mock State Between Tests](references/mock-clear-between-tests.md) — MEDIUM (Prevents call count and argument contamination between tests)
   - 3.4 [Maintain Type Safety in Mocks](references/mock-type-safety.md) — MEDIUM (Catches mock/implementation mismatches at compile time instead of runtime)
   - 3.5 [Understand vi.mock Hoisting Behavior](references/mock-vi-mock-hoisting.md) — HIGH (Prevents "module not mocked" errors and unexpected real implementations)
   - 3.6 [Use mockImplementation for Dynamic Mocks](references/mock-implementation-not-value.md) — HIGH (Enables context-aware mocks that respond differently based on input)
   - 3.7 [Use MSW for Network Request Mocking](references/mock-msw-network.md) — HIGH (Provides realistic request/response mocking at the network level)
4. [Performance](references/_sections.md#4-performance) — **HIGH**
   - 4.1 [Choose the Right Pool for Performance](references/perf-pool-selection.md) — HIGH (2-5× performance difference between pool types on large test suites)
   - 4.2 [Disable Test Isolation When Safe](references/perf-disable-isolation.md) — HIGH (30-50% faster test execution for well-isolated tests)
   - 4.3 [Use Bail for Fast Failure in CI](references/perf-bail-fast-fail.md) — MEDIUM (Saves CI minutes by stopping early when tests fail)
   - 4.4 [Use happy-dom Over jsdom When Possible](references/perf-happy-dom.md) — HIGH (2-3× faster DOM operations compared to jsdom)
   - 4.5 [Use Run Mode in CI Environments](references/perf-run-mode-ci.md) — MEDIUM (Avoids watch mode overhead and file system polling in CI)
   - 4.6 [Use Sharding for CI Parallelization](references/perf-sharding.md) — HIGH (Linear speedup with additional CI nodes (3 nodes = ~3× faster))
5. [Snapshot Testing](references/_sections.md#5-snapshot-testing) — **MEDIUM**
   - 5.1 [Avoid Large Snapshots](references/snap-avoid-large.md) — MEDIUM (Large snapshots are rarely reviewed and blindly updated, masking real bugs)
   - 5.2 [Ensure Stable Snapshot Serialization](references/snap-stable-serialization.md) — MEDIUM (Eliminates false snapshot failures from non-deterministic data)
   - 5.3 [Name Snapshot Tests Descriptively](references/snap-describe-intent.md) — LOW (Improves snapshot file organization and failure debugging)
   - 5.4 [Prefer Inline Snapshots for Small Values](references/snap-inline-over-file.md) — MEDIUM (Improves test readability by showing expected output directly in test code)
   - 5.5 [Review Snapshot Updates Before Committing](references/snap-review-updates.md) — MEDIUM (Prevents bugs from being silently committed via blind snapshot updates)
6. [Environment](references/_sections.md#6-environment) — **MEDIUM**
   - 6.1 [Configure Globals Consistently](references/env-globals-config.md) — LOW (Determines whether imports are required for test APIs)
   - 6.2 [Mock Browser APIs Not Available in Test Environment](references/env-browser-api-mocking.md) — MEDIUM (Prevents "X is not defined" errors when testing browser-specific code)
   - 6.3 [Override Environment Per File When Needed](references/env-per-file-override.md) — MEDIUM (Allows mixing node and browser tests without separate config files)
   - 6.4 [Use Setup Files for Global Configuration](references/env-setup-files.md) — MEDIUM (Centralizes test setup and ensures consistent environment across all tests)
7. [Assertions](references/_sections.md#7-assertions) — **LOW-MEDIUM**
   - 7.1 [Choose toBe vs toEqual Correctly](references/assert-toequal-vs-tobe.md) — LOW (Prevents false positives from reference vs value comparison)
   - 7.2 [Test Edge Cases and Boundaries](references/assert-edge-cases.md) — MEDIUM (Catches bugs that happy-path-only tests miss)
   - 7.3 [Test One Concept Per Test](references/assert-one-assertion-concept.md) — LOW-MEDIUM (Improves failure diagnosis and test maintainability)
   - 7.4 [Use expect.assertions for Async Tests](references/assert-expect-assertions.md) — MEDIUM (Prevents tests from passing when async assertions are skipped)
   - 7.5 [Use Specific Matchers Over Generic Ones](references/assert-specific-matchers.md) — MEDIUM (Provides clearer failure messages and catches more specific bugs)
8. [Test Organization](references/_sections.md#8-test-organization) — **LOW**
   - 8.1 [Colocate Test Files with Source Files](references/org-file-colocation.md) — LOW (Reduces navigation overhead and improves test discoverability)
   - 8.2 [Use Describe Blocks for Logical Grouping](references/org-describe-nesting.md) — LOW (Improves test output readability and enables scoped setup/teardown)
   - 8.3 [Use skip and only Appropriately](references/org-test-skip-only.md) — LOW (Prevents accidentally committing focused or skipped tests)
   - 8.4 [Write Descriptive Test Names](references/org-test-naming.md) — LOW (Improves test documentation and failure debugging)

---

## References

1. [https://vitest.dev/guide/improving-performance](https://vitest.dev/guide/improving-performance)
2. [https://vitest.dev/guide/profiling-test-performance](https://vitest.dev/guide/profiling-test-performance)
3. [https://vitest.dev/guide/mocking](https://vitest.dev/guide/mocking)
4. [https://vitest.dev/guide/snapshot](https://vitest.dev/guide/snapshot)
5. [https://vitest.dev/guide/browser/component-testing](https://vitest.dev/guide/browser/component-testing)
6. [https://trunk.io/blog/how-to-avoid-and-detect-flaky-tests-in-vitest](https://trunk.io/blog/how-to-avoid-and-detect-flaky-tests-in-vitest)
7. [https://mswjs.io/docs/](https://mswjs.io/docs/)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |