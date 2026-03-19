---
name: rust-testing
description: Test design methodology for writing tests that catch real bugs in Rust codebases. Teaches how to think about WHAT to test and how to design test infrastructure, not just which assertion macros to use. Use this skill whenever writing Rust tests, designing test infrastructure, or reviewing test quality. Triggers on Rust testing, test design, regression tests, mock servers, snapshot testing, or test infrastructure.
---

# Rust Test Design Methodology

This skill teaches you to think about testing the way Michael Bolin does -- writing 3-6 targeted regression tests per PR where each one catches a specific future failure. It is not about tools. It is about judgment.

## The Core Question: "What Could Break?"

Before writing any test, ask:
1. What invariant does this code maintain?
2. What edge case would violate it?
3. What platform difference could surface?
4. What would a future refactor accidentally break?

Bolin's test PRs consistently cover: positive path, boundary conditions, bypass attempts, platform-specific behavior, and legacy compatibility. If your PR only has a happy-path test, it is incomplete.

## Test Naming as Documentation

A failed test name should be an actionable bug description. The pattern:
`{subject}_{behavior_or_scenario}_{expected_outcome}`

When a test fails in CI, the name alone should tell you what broke and where to look. Real test names from the codebase demonstrating this:

**Sandbox detection (positive, negative, boundary, platform):**
- `sandbox_detection_requires_keywords`
- `sandbox_detection_identifies_keyword_in_stderr`
- `sandbox_detection_respects_quick_reject_exit_codes`
- `sandbox_detection_ignores_non_sandbox_mode`
- `sandbox_detection_ignores_network_policy_text_in_non_sandbox_mode`
- `sandbox_detection_uses_aggregated_output`

**Output aggregation (boundary conditions and rebalancing):**
- `aggregate_output_prefers_stderr_on_contention`
- `aggregate_output_fills_remaining_capacity_with_stderr`
- `aggregate_output_rebalances_when_stderr_is_small`
- `aggregate_output_keeps_stdout_then_stderr_when_under_cap`

**Platform-specific behavior:**
- `windows_restricted_token_skips_external_sandbox_policies`
- `windows_restricted_token_runs_for_legacy_restricted_policies`
- `windows_restricted_token_rejects_network_only_restrictions`

**Feature flags (lifecycle states, aliases, dependencies):**
- `under_development_features_are_disabled_by_default`
- `default_enabled_features_are_stable`
- `use_legacy_landlock_is_stable_and_disabled_by_default`
- `js_repl_is_experimental_and_user_toggleable`
- `code_mode_only_requires_code_mode`
- `request_permissions_tool_is_under_development`
- `collab_is_legacy_alias_for_multi_agent`
- `apps_require_feature_flag_and_chatgpt_auth`

**Error formatting (per-variant, per-plan):**
- `usage_limit_reached_error_formats_plus_plan`
- `usage_limit_reached_error_formats_free_plan`
- `usage_limit_reached_error_formats_go_plan`
- `unexpected_status_cloudflare_html_is_simplified`
- `sandbox_denied_uses_aggregated_output_when_stderr_empty`
- `sandbox_denied_reports_both_streams_when_available`
- `sandbox_denied_reports_exit_code_when_no_output_available`

**Config validation (accept valid, reject invalid, legacy compat):**
- `config_toml_deserializes_permission_profiles`
- `permissions_profiles_network_populates_runtime_network_proxy_spec`
- `default_permissions_profile_populates_runtime_sandbox_policy`
- `permissions_profiles_require_default_permissions`
- `permissions_profiles_reject_writes_outside_workspace_root`
- `permissions_profiles_reject_nested_entries_for_non_project_roots`
- `permissions_profiles_reject_project_root_parent_traversal`
- `permissions_profiles_allow_network_enablement`
- `legacy_sandbox_mode_config_builds_split_policies_without_drift`

Notice the pattern across every group: positive path, rejection, edge case, platform variant, legacy compat.

## The Regression Test Checklist

For every PR, verify you have covered:
- [ ] The happy path (it actually works)
- [ ] The error path (graceful failure, not a panic)
- [ ] The edge case (boundary conditions, empty inputs, degenerate data)
- [ ] Platform differences (if `#[cfg]` is involved)
- [ ] The invariant that motivated the change
- [ ] Legacy compatibility (if replacing or extending existing behavior)

## Test File Organization

Production code and test code live in sibling files, not inline:

```rust
// In feature.rs (production code), at the bottom:
#[cfg(test)]
#[path = "feature_tests.rs"]
mod tests;
```

The test file begins with `use super::*;` and contains all `#[test]` and `#[tokio::test]` functions plus test-only helpers. For `mod.rs` modules, use `mod_tests.rs`.

This keeps production modules focused on runtime code. Test changes do not pollute production file diffs in review.

## Test Data Construction

Build test data as typed structs, never as JSON strings. Compile-time safety catches field additions and renames that JSON would silently miss.

```rust
fn make_exec_output(
    exit_code: i32,
    stdout: &str,
    stderr: &str,
    aggregated: &str,
) -> ExecToolCallOutput {
    ExecToolCallOutput {
        exit_code,
        stdout: StreamOutput::new(stdout.to_string()),
        stderr: StreamOutput::new(stderr.to_string()),
        aggregated_output: StreamOutput::new(aggregated.to_string()),
        duration: Duration::from_millis(1),
        timed_out: false,
    }
}
```

Use factory functions for common domain objects (e.g. `stdio_mcp(command)` for `McpServerConfig`, `TestCodexBuilder::new()` for test instances). Each test constructs exactly the fixture it needs. No shared mutable state. No JSON parsing at test time.

## Assertions That Actually Help

- **Always** `use pretty_assertions::assert_eq;` -- colored diffs on failure.
- **Compare entire objects**, not individual fields. Field-by-field assertions miss unexpected changes to other fields.
- `assert_matches!` for enum variant checks without destructuring every field.
- Descriptive panic messages when using `assert!`:
  ```rust
  assert!(result.is_ok(), "expected valid config but got: {result:?}");
  ```

## The Testing Stack

### HTTP Tests: wiremock + ResponseMock

For any test that hits the Responses API, use the `core_test_support::responses` helpers:

```rust
let mock = responses::mount_sse_once(&server, responses::sse(vec![
    responses::ev_response_created("resp-1"),
    responses::ev_function_call("call-1", "shell", &serde_json::to_string(&args)?),
    responses::ev_completed("resp-1"),
])).await;

codex.submit(Op::UserTurn { ... }).await?;

// Assert the outbound request body:
let request = mock.single_request();
let output = request.function_call_output("call-1");
```

Key helpers:
- `mount_sse_once` -- mount a one-shot SSE response on wiremock.
- `sse(vec![...])` -- build an SSE body from a list of `ev_*` event values.
- `ev_response_created`, `ev_function_call`, `ev_completed` -- typed SSE event constructors.
- `ResponseMock::single_request()` -- assert exactly one request was captured.
- `ResponseMock::requests()` -- inspect all captured `ResponsesRequest` objects.
- `ResponsesRequest` exposes `.body_json()`, `.input()`, `.function_call_output(call_id)`, `.header()`, `.instructions_text()`, etc.

### Async Event Tests: wait_for_event

The core loop for testing the agent protocol:

```rust
codex.submit(Op::UserTurn {
    content: UserInput::text("write hello.txt"),
}).await?;

let event = wait_for_event(&codex, |ev| {
    matches!(ev, EventMsg::ExecApprovalRequest { .. })
}).await;
```

- `wait_for_event` takes a predicate closure, polls `codex.next_event()`, and returns the first match.
- `wait_for_event_match` extracts a value from the matching event (returns `T` instead of `EventMsg`).
- Prefer `wait_for_event` over `wait_for_event_with_timeout` -- the default timeout is sufficient.

### Filesystem Tests: TempDir Isolation

Every test that touches disk gets its own `TempDir`. Never mutate the process environment.

```rust
let tmp = TempDir::new()?;
let config = TestCodexBuilder::new()
    .with_config(|c| c.cwd = tmp.path().to_owned())
    .build(&server).await?;
```

The `TestCodexBuilder` pattern provides a fluent API for configuring test instances with custom config, auth, shell overrides, and pre-build hooks.

### UI Tests: insta Snapshots

For TUI widgets: render to a `Buffer` at a known width, convert rows to a string, snapshot with `assert_snapshot!`:

```rust
fn render_lines(view: &impl Widget, width: u16, height: u16) -> String {
    let area = Rect::new(0, 0, width, height);
    let mut buf = Buffer::empty(area);
    view.render(area, &mut buf);
    // Convert buffer cells row-by-row into a plain string.
    (0..height).map(|row| /* collect symbols */).collect::<Vec<_>>().join("\n")
}

#[test]
fn setup_view_snapshot_uses_runtime_preview_values() {
    let view = StatusLineSetupView::new(/* known data */);
    assert_snapshot!(render_lines(&view, 72, 10));
}
```

Workflow:
1. `cargo test -p codex-tui` -- generates `.snap.new` files for changed output.
2. `cargo insta pending-snapshots -p codex-tui` -- see what changed.
3. Read the `.snap.new` files directly to review.
4. `cargo insta accept -p codex-tui` -- accept all new snapshots.

Every UI change needs snapshot coverage. If you add new UI, add a new snapshot test.

## Determinism

- Use `BTreeMap` over `HashMap` when output order affects test assertions.
- `set_deterministic_process_ids(true)` for stable exec IDs in tests.
- `set_thread_manager_test_mode(true)` for reproducible thread behavior.
- Never rely on wall-clock timing. Use `wait_for_event` predicates, not sleep.
- Prefer `codex_utils_cargo_bin::cargo_bin("name")` for binary resolution (works under both Cargo and Bazel).
- Use `codex_utils_cargo_bin::find_resource!("path")` for fixture files.

## Cross-Platform Testing Judgment

When writing tests that involve platform-specific code:

```rust
// The test only makes sense on Windows:
#[cfg(windows)]
#[test]
fn windows_restricted_token_skips_external_sandbox_policies() { ... }

// Cross-platform path helpers:
fn test_path_buf(unix_path: &str) -> PathBuf {
    test_path_buf_with_windows(unix_path, None)
}
```

Use the `test_path_buf` and `test_absolute_path` helpers from `core_test_support` for paths that must work on both Unix and Windows. Never hardcode `/tmp` or `C:\` directly.

## Quick Reference: Testing Commands

```bash
# Run tests for a specific crate:
cargo test -p codex-core --lib

# Run a single test by name:
cargo test -p codex-core -- sandbox_detection_requires_keywords

# Run integration tests:
cargo test -p codex-core --test all

# Snapshot workflow:
cargo test -p codex-tui
cargo insta pending-snapshots -p codex-tui
cargo insta accept -p codex-tui

# Format and lint after changes:
just fmt
just fix -p codex-core
```

## Anti-Patterns

- **One giant happy-path test.** If it passes, you learn nothing about failure modes.
- **JSON string construction for test data.** Breaks silently when fields change.
- **`assert!(result.is_ok())` without the error.** Use `assert!(result.is_ok(), "msg: {result:?}")`.
- **Inline test modules.** Use sibling `_tests.rs` files.
- **Shared mutable state between tests.** Each test gets its own `TempDir`, its own mock server.
- **Sleeping instead of waiting.** Use `wait_for_event` with a predicate, not `tokio::time::sleep`.
- **Field-by-field assertions.** Compare the whole struct. Catch the field you did not expect to change.
- **`HashMap` in assertions.** Non-deterministic iteration order. Use `BTreeMap`.
