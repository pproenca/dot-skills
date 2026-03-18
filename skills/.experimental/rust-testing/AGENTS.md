# Rust Testing

**Version 1.0.0**  
Codex-RS Contributors  
March 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive testing best practices guide for Rust codebases, designed for AI agents and LLMs. Contains 40 rules across 8 categories, prioritized by impact from critical (test architecture, assertions) to incremental (integration test patterns). Each rule includes detailed explanations, real-world examples from the codex-rs codebase comparing incorrect vs. correct test implementations, and specific impact metrics to guide automated test generation.

---

## Table of Contents

1. [Test Architecture](references/_sections.md#1-test-architecture) — **CRITICAL**
   - 1.1 [Avoid Mutating Process Environment in Tests](references/arch-avoid-env-mutation.md) — CRITICAL (eliminates nondeterministic failures from shared global state)
   - 1.2 [Place Tests in Sibling _tests.rs Files](references/arch-sibling-test-files.md) — CRITICAL (reduces merge conflicts by 60-80% in high-churn modules)
   - 1.3 [Use cargo_bin for Binary Resolution in Tests](references/arch-cargo-bin-resolver.md) — CRITICAL (100% binary resolution success under both Cargo and Bazel)
   - 1.4 [Use Standard Test Module Imports](references/arch-test-module-imports.md) — CRITICAL (ensures consistent test utilities across 100% of test modules)
   - 1.5 [Use TempDir for Filesystem Test Isolation](references/arch-tempdir-isolation.md) — CRITICAL (eliminates cross-test filesystem pollution in 100% of IO tests)
   - 1.6 [Write Regression Tests for Every Bug Fix](references/arch-regression-per-pr.md) — CRITICAL (3-6 regression tests per PR prevents bug reintroduction)
2. [Assertions](references/_sections.md#2-assertions) — **CRITICAL**
   - 2.1 [Compare Entire Objects Not Individual Fields](references/assert-whole-object.md) — CRITICAL (catches 100% of unexpected field changes that field-by-field checks miss)
   - 2.2 [Use assert_eq Over assert with Boolean Expressions](references/assert-eq-over-bool.md) — CRITICAL (3-5x faster debugging with actual vs expected values on failure)
   - 2.3 [Use assert_snapshot for UI Render Output](references/assert-snapshot-ui.md) — CRITICAL (100% visual coverage of UI changes reviewable in PR diffs)
   - 2.4 [Use pretty_assertions for All Equality Checks](references/assert-pretty-assertions.md) — CRITICAL (5-10x faster failure diagnosis with colored diffs)
   - 2.5 [Use Self-Documenting Test Function Names](references/assert-descriptive-names.md) — CRITICAL (2-5x faster failure triage from self-documenting test names)
3. [Mock Servers](references/_sections.md#3-mock-servers) — **HIGH**
   - 3.1 [Build SSE Payloads with ev_ Constructors](references/mock-sse-builders.md) — HIGH (10-20x reduction in SSE payload construction code)
   - 3.2 [Prefer mount_sse_once for SSE Response Mocking](references/mock-mount-sse-once.md) — HIGH (reduces SSE mock setup from 15+ lines to 3-5 lines)
   - 3.3 [Prefer wait_for_event Over wait_for_event_with_timeout](references/mock-wait-for-event.md) — HIGH (reduces test boilerplate by using the sensible 1-second default timeout)
   - 3.4 [Use core_test_support responses Utilities](references/mock-responses-helpers.md) — HIGH (reduces mock setup from 20+ lines to 3-5 lines per test)
   - 3.5 [Use ResponseMock for Request Body Assertions](references/mock-response-mock.md) — HIGH (enables structured assertions on captured HTTP request payloads)
   - 3.6 [Use wiremock MockServer for HTTP Testing](references/mock-wiremock-setup.md) — HIGH (eliminates network dependency in 100% of integration tests)
4. [Test Data](references/_sections.md#4-test-data) — **HIGH**
   - 4.1 [Construct Test Data as Typed Structs Not JSON](references/data-struct-construction.md) — HIGH (100% compile-time detection of field renames vs 0% with JSON)
   - 4.2 [Use BTreeMap in Tests for Deterministic Ordering](references/data-btreemap-tests.md) — HIGH (eliminates nondeterministic assertion failures from HashMap ordering)
   - 4.3 [Use Builder Functions for Complex Test Objects](references/data-builder-pattern.md) — HIGH (reduces test setup from 30+ lines to 3-5 lines per test)
   - 4.4 [Use Domain-Realistic Names in Test Data](references/data-realistic-names.md) — HIGH (2-3x faster test comprehension from domain-specific identifiers)
   - 4.5 [Use Minimal Fixtures That Test One Thing](references/data-minimal-fixtures.md) — HIGH (reduces test maintenance burden by 50% when data structures change)
5. [Event Testing](references/_sections.md#5-event-testing) — **MEDIUM-HIGH**
   - 5.1 [Assert Function Call Output in Mock Tests](references/event-function-call-output.md) — MEDIUM-HIGH (100% verification coverage of outbound tool call outputs)
   - 5.2 [Use codex submit Op for Integration Tests](references/event-submit-op.md) — MEDIUM-HIGH (100% protocol path coverage from input to event emission)
   - 5.3 [Use ResponsesRequest Helpers for Body Assertions](references/event-request-helpers.md) — MEDIUM-HIGH (5-10x less assertion code with typed helper methods)
   - 5.4 [Use Structured Payload Assertions](references/event-structured-assertions.md) — MEDIUM-HIGH (3-5x more resilient assertions via parsed JSON vs raw strings)
   - 5.5 [Use wait_for_event with Predicate Closures](references/event-wait-for-event.md) — MEDIUM-HIGH (100% resilience to event reordering vs 0% with positional indexing)
6. [Determinism](references/_sections.md#6-determinism) — **MEDIUM**
   - 6.1 [Avoid Test Dependency on Process Environment](references/det-no-env-dependency.md) — MEDIUM (prevents failures when tests run in CI, containers, or sandboxed environments)
   - 6.2 [Avoid Timing-Dependent Assertions](references/det-no-timing-assertions.md) — MEDIUM (prevents flaky failures on slow CI machines and under load)
   - 6.3 [Handle Sandbox Environment Variables Gracefully](references/det-sandbox-env-skip.md) — MEDIUM (100% graceful skip rate in sandboxed CI environments)
   - 6.4 [Use set_deterministic_process_ids in Tests](references/det-deterministic-ids.md) — MEDIUM (ensures snapshot tests produce stable output across all test runs)
   - 6.5 [Use Sorted Collections for Reproducible Serialization](references/det-fixed-ordering.md) — MEDIUM (eliminates HashMap-ordering-dependent test failures across platforms)
7. [Snapshot Testing](references/_sections.md#7-snapshot-testing) — **MEDIUM**
   - 7.1 [Follow the cargo insta Test Accept Workflow](references/snap-cargo-insta-workflow.md) — MEDIUM (100% snapshot review rate before acceptance)
   - 7.2 [Review snap.new Files Before Accepting](references/snap-review-snap-new.md) — MEDIUM (prevents accidental acceptance of incorrect snapshots in 100% of cases)
   - 7.3 [Use Buffer Rendering for TUI Snapshot Tests](references/snap-tui-render-pattern.md) — MEDIUM (100% pixel-accurate terminal output capture for comparison)
   - 7.4 [Use Insta Snapshots for All UI Changes](references/snap-ui-coverage.md) — MEDIUM (makes UI impact reviewable in PR diffs for 100% of visual changes)
8. [Integration Tests](references/_sections.md#8-integration-tests) — **LOW-MEDIUM**
   - 8.1 [Run cargo test -p for Scoped Test Execution](references/integ-scoped-test-execution.md) — LOW-MEDIUM (5-10x faster feedback by running only affected crate tests)
   - 8.2 [Test Both tui and tui_app_server for Shared Behavior](references/integ-mirror-tui-tests.md) — LOW-MEDIUM (100% behavioral parity between tui and tui_app_server)
   - 8.3 [Use core_test_support for End-to-End Tests](references/integ-core-test-support.md) — LOW-MEDIUM (reduces integration test boilerplate by 80%)
   - 8.4 [Use find_resource for Bazel-Compatible Fixture Paths](references/integ-find-resource.md) — LOW-MEDIUM (100% fixture path resolution under both Cargo and Bazel)

---

## References

1. [https://github.com/openai/codex](https://github.com/openai/codex)
2. [https://doc.rust-lang.org/book/ch11-00-testing.html](https://doc.rust-lang.org/book/ch11-00-testing.html)
3. [https://crates.io/crates/insta](https://crates.io/crates/insta)
4. [https://crates.io/crates/wiremock](https://crates.io/crates/wiremock)
5. [https://crates.io/crates/pretty_assertions](https://crates.io/crates/pretty_assertions)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |