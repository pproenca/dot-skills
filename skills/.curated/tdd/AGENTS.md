# Test-Driven Development

**Version 0.1.0**  
Community  
January 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive guide to Test-Driven Development practices, designed for AI agents and LLMs. Contains 42 rules across 8 categories, prioritized by impact from critical (red-green-refactor cycle, test design principles) to strategic (test pyramid, coverage targets). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide test writing, refactoring, and code generation.

---

## Table of Contents

1. [Red-Green-Refactor Cycle](references/_sections.md#1-red-green-refactor-cycle) — **CRITICAL**
   - 1.1 [Maintain a Test List](references/cycle-maintain-test-list.md) — CRITICAL (prevents scope creep and forgotten cases)
   - 1.2 [Refactor Immediately After Green](references/cycle-refactor-after-green.md) — CRITICAL (prevents technical debt accumulation)
   - 1.3 [Take Small Incremental Steps](references/cycle-small-increments.md) — CRITICAL (2-5× faster debugging from smaller change sets)
   - 1.4 [Verify the Test Fails Before Writing Code](references/cycle-verify-test-fails-first.md) — CRITICAL (prevents false positives from untested code)
   - 1.5 [Write Only Enough Code to Pass the Test](references/cycle-minimal-code-to-pass.md) — CRITICAL (prevents over-engineering and YAGNI violations)
   - 1.6 [Write the Test Before the Implementation](references/cycle-write-test-first.md) — CRITICAL (prevents 40-90% of defects)
2. [Test Design Principles](references/_sections.md#2-test-design-principles) — **CRITICAL**
   - 2.1 [Avoid Logic in Tests](references/design-avoid-logic-in-tests.md) — CRITICAL (eliminates bugs in test code itself)
   - 2.2 [Follow the Arrange-Act-Assert Pattern](references/design-aaa-pattern.md) — CRITICAL (makes tests 2-3× more readable)
   - 2.3 [One Logical Assertion Per Test](references/design-one-assertion-per-test.md) — CRITICAL (reduces failure diagnosis time to O(1))
   - 2.4 [Test Behavior Not Implementation](references/design-test-behavior-not-implementation.md) — CRITICAL (reduces test brittleness by 50-80%)
   - 2.5 [Test Edge Cases and Boundaries](references/design-test-edge-cases.md) — CRITICAL (catches 60-80% of production bugs)
   - 2.6 [Use Descriptive Test Names](references/design-descriptive-test-names.md) — CRITICAL (2-3× faster failure diagnosis)
3. [Test Isolation & Dependencies](references/_sections.md#3-test-isolation-&-dependencies) — **HIGH**
   - 3.1 [Avoid Shared Mutable State Between Tests](references/isolate-no-shared-state.md) — HIGH (eliminates 74% of test order dependency bugs)
   - 3.2 [Mock External Dependencies](references/isolate-mock-external-dependencies.md) — HIGH (makes tests 10-100× faster)
   - 3.3 [Prefer Stubs Over Mocks for Queries](references/isolate-prefer-stubs-over-mocks.md) — HIGH (reduces test brittleness)
   - 3.4 [Use Dependency Injection for Testability](references/isolate-use-dependency-injection.md) — HIGH (enables isolation without hacks)
   - 3.5 [Write Deterministic Tests](references/isolate-deterministic-tests.md) — HIGH (eliminates flaky test failures)
4. [Test Data Management](references/_sections.md#4-test-data-management) — **HIGH**
   - 4.1 [Avoid Mystery Guests](references/data-avoid-mystery-guests.md) — HIGH (2-3× faster test comprehension)
   - 4.2 [Keep Test Setup Minimal](references/data-minimal-setup.md) — HIGH (2-5× faster test execution and comprehension)
   - 4.3 [Use Builder Pattern for Complex Objects](references/data-builder-pattern.md) — HIGH (reduces complex setup code by 40-60%)
   - 4.4 [Use Factories for Test Data Creation](references/data-use-factories.md) — HIGH (reduces test setup code by 60-80%)
   - 4.5 [Use Unique Identifiers Per Test](references/data-unique-identifiers.md) — HIGH (prevents test pollution)
5. [Assertions & Verification](references/_sections.md#5-assertions-&-verification) — **MEDIUM**
   - 5.1 [Assert on Error Messages and Types](references/assert-error-messages.md) — MEDIUM (prevents false positives from wrong errors)
   - 5.2 [Create Custom Matchers for Domain Assertions](references/assert-custom-matchers.md) — MEDIUM (reduces assertion code by 60-80%)
   - 5.3 [Every Test Must Have Assertions](references/assert-no-assertions-antipattern.md) — MEDIUM (prevents false passing tests)
   - 5.4 [Use Snapshot Testing Judiciously](references/assert-snapshot-testing.md) — MEDIUM (prevents snapshot blindness)
   - 5.5 [Use Specific Assertions](references/assert-specific-assertions.md) — MEDIUM (2-5× faster debugging from better failure messages)
6. [Test Organization & Structure](references/_sections.md#6-test-organization-&-structure) — **MEDIUM**
   - 6.1 [Extract Reusable Test Utilities](references/org-test-utilities.md) — MEDIUM (reduces duplication by 40-60%)
   - 6.2 [Follow Consistent Test File Structure](references/org-file-structure.md) — MEDIUM (reduces time finding tests)
   - 6.3 [Group Tests by Behavior Not Method](references/org-group-by-behavior.md) — MEDIUM (2-3× faster test navigation and discovery)
   - 6.4 [Use Parameterized Tests for Variations](references/org-parameterized-tests.md) — MEDIUM (reduces test code by 50-70%)
   - 6.5 [Use Setup and Teardown Hooks Appropriately](references/org-setup-teardown.md) — MEDIUM (reduces setup duplication by 30-50%)
7. [Test Performance & Reliability](references/_sections.md#7-test-performance-&-reliability) — **MEDIUM**
   - 7.1 [Avoid Arbitrary Sleep Calls](references/perf-avoid-sleep.md) — MEDIUM (eliminates 54% of async-related flakiness)
   - 7.2 [Eliminate Network Calls in Unit Tests](references/perf-avoid-network-calls.md) — MEDIUM (makes tests 10-100× faster)
   - 7.3 [Fix Flaky Tests Immediately](references/perf-fix-flaky-tests.md) — MEDIUM (preserves trust in test suite)
   - 7.4 [Keep Unit Tests Under 100ms](references/perf-fast-unit-tests.md) — MEDIUM (enables rapid feedback loops)
   - 7.5 [Parallelize Independent Tests](references/perf-parallelize-tests.md) — MEDIUM (reduces suite time by 50-80%)
8. [Test Pyramid & Strategy](references/_sections.md#8-test-pyramid-&-strategy) — **LOW**
   - 8.1 [Follow the Test Pyramid](references/strat-test-pyramid.md) — LOW (reduces test infrastructure cost by 10-100×)
   - 8.2 [Limit E2E Tests to Critical User Paths](references/strat-e2e-critical-paths.md) — LOW (reduces maintenance burden)
   - 8.3 [Set Meaningful Coverage Targets](references/strat-coverage-targets.md) — LOW (2-3× better ROI on testing effort)
   - 8.4 [Test Integration at Service Boundaries](references/strat-integration-boundaries.md) — LOW (prevents integration failures in production)
   - 8.5 [Use Mutation Testing to Validate Test Quality](references/strat-mutation-testing.md) — LOW (detects 30-50% more weak assertions)

---

## References

1. [https://martinfowler.com/bliki/TestDrivenDevelopment.html](https://martinfowler.com/bliki/TestDrivenDevelopment.html)
2. [http://blog.cleancoder.com/uncle-bob/2014/12/17/TheCyclesOfTDD.html](http://blog.cleancoder.com/uncle-bob/2014/12/17/TheCyclesOfTDD.html)
3. [https://learn.microsoft.com/en-us/dotnet/core/testing/unit-testing-best-practices](https://learn.microsoft.com/en-us/dotnet/core/testing/unit-testing-best-practices)
4. [https://testing.googleblog.com/2020/08/code-coverage-best-practices.html](https://testing.googleblog.com/2020/08/code-coverage-best-practices.html)
5. [https://semaphore.io/blog/aaa-pattern-test-automation](https://semaphore.io/blog/aaa-pattern-test-automation)
6. [https://docs.pytest.org/en/stable/how-to/fixtures.html](https://docs.pytest.org/en/stable/how-to/fixtures.html)
7. [https://martinfowler.com/articles/practical-test-pyramid.html](https://martinfowler.com/articles/practical-test-pyramid.html)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |