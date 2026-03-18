---
name: rust-testing
description: Rust testing best practices covering test architecture, assertions, mocking, snapshots, event testing, determinism, and integration patterns for the codex-rs codebase
---

# Codex-RS Contributors Rust Testing Best Practices

A comprehensive guide to writing high-quality Rust tests at the standard established by the top codex-rs contributors. This skill encodes patterns for test architecture, assertions, mock servers, test data, event-driven testing, determinism, snapshot testing, and integration test infrastructure.

## When to Apply

- Writing new tests for any Rust module in codex-rs
- Adding regression tests for a bug fix (3-6 tests per PR)
- Creating integration tests that interact with the Responses API via SSE mocks
- Modifying TUI rendering code that requires snapshot coverage
- Reviewing test code for adherence to codebase conventions

## Rule Categories by Priority

| Priority | Category | Prefix | Rules | Focus |
|----------|----------|--------|-------|-------|
| CRITICAL | Test Architecture | `arch-` | 6 | File organization, imports, isolation |
| CRITICAL | Assertions | `assert-` | 5 | pretty_assertions, whole-object comparison |
| HIGH | Mock Servers | `mock-` | 6 | wiremock, SSE builders, ResponseMock |
| HIGH | Test Data | `data-` | 5 | Builders, typed construction, BTreeMap |
| MEDIUM-HIGH | Event Testing | `event-` | 5 | submit/wait cycles, predicate matching |
| MEDIUM | Determinism | `det-` | 5 | Stable IDs, environment isolation |
| MEDIUM | Snapshot Testing | `snap-` | 4 | Insta workflow, buffer rendering |
| LOW-MEDIUM | Integration Tests | `integ-` | 4 | core_test_support, Bazel compatibility |

## Quick Reference

- **Test file placement:** Sibling `_tests.rs` via `#[path = "feature_tests.rs"]`
- **Assertions:** Always `use pretty_assertions::assert_eq;`
- **Object comparison:** `assert_eq!(actual, expected)` on entire structs
- **SSE mocking:** `responses::mount_sse_once` + `responses::sse(vec![ev_*(...)])`
- **Event waiting:** `wait_for_event(codex, |ev| predicate)`
- **Snapshot tests:** `insta::assert_snapshot!(terminal.backend())`
- **Determinism:** `BTreeMap` over `HashMap`, `set_deterministic_process_ids`
- **Binary resolution:** `codex_utils_cargo_bin::cargo_bin("name")`
- **Fixture paths:** `codex_utils_cargo_bin::find_resource!("path")`
- **Sandbox handling:** `skip_if_sandbox!()` / `skip_if_no_network!()`

## How to Use

1. Start with CRITICAL rules (arch, assert) — these apply to every test
2. Apply HIGH rules (mock, data) when writing integration tests with API mocks
3. Apply MEDIUM-HIGH rules (event) when testing the agent protocol
4. Apply MEDIUM rules (det, snap) when tests involve process IDs or UI rendering
5. Apply LOW-MEDIUM rules (integ) for cross-crate and build-system compatibility

## Reference Files

| File | Purpose |
|------|---------|
| `references/_sections.md` | Section definitions, ordering, and impact levels |
| `references/arch-*.md` | Test architecture rules (6 files) |
| `references/assert-*.md` | Assertion rules (5 files) |
| `references/mock-*.md` | Mock server rules (6 files) |
| `references/data-*.md` | Test data rules (5 files) |
| `references/event-*.md` | Event testing rules (5 files) |
| `references/det-*.md` | Determinism rules (5 files) |
| `references/snap-*.md` | Snapshot testing rules (4 files) |
| `references/integ-*.md` | Integration test rules (4 files) |
| `assets/templates/_template.md` | Rule file template |
| `metadata.json` | Skill metadata and version |
